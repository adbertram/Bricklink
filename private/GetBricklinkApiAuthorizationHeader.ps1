function GetBricklinkApiAuthorizationHeader {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Uri,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('GET', 'POST', 'PUT')]
        [string]$Method,
        
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ConsumerKey = $script:bricklinkConfiguration.'secret-values'.'api-consumer-key',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ConsumerSecret = $script:bricklinkConfiguration.'secret-values'.'api-consumer-secret',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Token = $script:bricklinkConfiguration.'secret-values'.'api-token',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$TokenSecret = $script:bricklinkConfiguration.'secret-values'.'api-token-secret'
    )

    $ErrorActionPreference = 'Stop'

    Add-Type -TypeDefinition @'

#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Security.Cryptography;
using System.Text;

namespace BrickLink {

internal static class WebUtils
{
    public static IEnumerable<WebParameter> ParseQueryString(Uri uri)
    {
        var parsedQuery = HttpUtility.ParseQueryString(uri.Query);

        var queryStringParameters = parsedQuery
            .AllKeys
            .SelectMany(parsedQuery.GetValues!, (key, value) => new { key, value });

        return queryStringParameters.Select(p => new WebParameter(p.key!, p.value!));
    }
}

public class WebParameter : IComparable<WebParameter>, IComparable
{
    public string Name { get;  }

    public string Value { get; }

    public WebParameter(string name, string value)
    {
        Name = name;
        Value = value;
    }

    public override string ToString()
    {
        return $"{Name}={Value}";
    }

    public int CompareTo(WebParameter? other)
    {
        if (ReferenceEquals(this, other))
        {
            return 0;
        }

        if (other is null)
        {
            return 1;
        }

        var nameComparison = string.Compare(Name, other.Name, StringComparison.Ordinal);

        if (nameComparison != 0)
        {
            return nameComparison;
        }

        return string.Compare(Value, other.Value, StringComparison.Ordinal);
    }

    public int CompareTo(object? obj)
    {
        if (obj is WebParameter webParameter)
        {
            return CompareTo(webParameter);
        }

        throw new ArgumentException($"{nameof(obj)} must be of type {typeof(WebParameter)}," +
                                    $"received {obj?.GetType().ToString() ?? "Null"}.");
    }
}

internal static class OAuthUtilities
{
    private static readonly DateTime _jan011970 = new DateTime(1970, 1, 1);
    private static readonly object _randomLock = new object();
    private static readonly Random _random = new Random();

    private static string ConstructRequestUrl(Uri url)
    {
        var builder = new StringBuilder();
        var requestUrl = $"{url.Scheme}://{url.Host}";
        var qualified = $":{url.Port}";
        var isBasic = url.Scheme == "http" && url.Port == 80;
        var isSecure = url.Scheme == "https" && url.Port == 443;
        builder.Append(requestUrl);
        builder.Append(!isBasic && !isSecure ? qualified : "");
        builder.Append(url.AbsolutePath);
        return builder.ToString();
    }

    private static string GetKey(string consumerSecret, string tokenSecret)
    {
        var builder = new StringBuilder();
        builder.Append(Uri.EscapeDataString(consumerSecret));
        builder.Append("&");
        builder.Append(Uri.EscapeDataString(tokenSecret));
        return builder.ToString();
    }

    private static string GetHmacSha1Hash(string signatureBaseString, string key)
    {
        var keyBytes = Encoding.UTF8.GetBytes(key);
        var baseStringBytes = Encoding.UTF8.GetBytes(signatureBaseString);
        using var sha1 = new HMACSHA1(keyBytes);
        var hash = sha1.ComputeHash(baseStringBytes);
        var base64 = Convert.ToBase64String(hash);
        return base64;
    }

    private static string Concatenate(List<WebParameter> collection, string separator, string spacer)
    {
        var builder = new StringBuilder();

        var total = collection.Count;
        var count = 0;

        foreach (var item in collection)
        {
            builder.Append(item.Name);
            builder.Append(separator);
            builder.Append(UrlEncodeStrict(item.Value));

            count++;

            if (count < total)
            {
                builder.Append(spacer);
            }
        }

        return builder.ToString();
    }

    private static string NormalizeRequestParameters(List<WebParameter> parameters)
    {
        parameters.Sort();
        var concatenated = Concatenate(parameters, "=", "&");
        return concatenated;
    }

    private static string PercentEncode(string s)
    {
        var bytes = Encoding.UTF8.GetBytes(s);
        var builder = new StringBuilder();

        foreach (var b in bytes)
        {
            if (b > 7 && b < 11 || b == 13)
            {
                builder.Append($"%0{b:X}");
            }
            else
            {
                builder.Append($"%{b:X}");
            }
        }
        return builder.ToString();
    }

    private static string UrlEncodeStrict(string value)
    {
        const string unreserved = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-._~";
        var original = value;
        var ret = original.Where(c => !unreserved.Contains(c) && c != '%')
            .Aggregate(value, (current, c) => current.Replace(c.ToString(), PercentEncode(c.ToString())));
        return ret.Replace("%%", "%25%");
    }

    internal static string GetSignature(string signatureBase, string consumerSecret, string tokenSecret)
    {
        var key = GetKey(consumerSecret, tokenSecret);
        var signature = GetHmacSha1Hash(signatureBase, key);
        return Uri.EscapeDataString(signature);
    }

    internal static string ConcatenateRequestElements(string method, string url, List<WebParameter> parameters)
    {
        var builder = new StringBuilder();
        var requestMethod = string.Concat(method.ToUpperInvariant(), "&");
        var uri = new Uri(url);
        var requestUrl = string.Concat(Uri.EscapeDataString(ConstructRequestUrl(uri)), "&");
        parameters.AddRange(WebUtils.ParseQueryString(uri));
        var normalizedRequestParams = NormalizeRequestParameters(parameters);
        var requestParameters = Uri.EscapeDataString(normalizedRequestParams);
        builder.Append(requestMethod);
        builder.Append(requestUrl);
        builder.Append(requestParameters);
        return builder.ToString();
    }

    internal static string GetNonce()
    {
        const string chars = "abcdefghijklmnopqrstuvwxyz1234567890";

        var nonce = new char[16];
        lock (_randomLock)
        {
            for (var i = 0; i < nonce.Length; i++)
            {
                nonce[i] = chars[_random.Next(0, chars.Length)];
            }
        }
        return new string(nonce);
    }

    internal static string GetTimestamp()
    {
        var timeSpan = DateTime.UtcNow - _jan011970;
        var timestamp = (long)timeSpan.TotalSeconds;
        return timestamp.ToString();
    }
}

public class OAuthRequest
{
    private readonly string _consumerKey;
    private readonly string _consumerSecret;
    private readonly string _token;
    private readonly string _tokenSecret;
    private readonly string _requestUrl;
    private readonly string _method;

    public OAuthRequest(string consumerKey, string consumerSecret, string token, string tokenSecret, string requestUrl, string method)
    {
        _consumerKey = consumerKey;
        _consumerSecret = consumerSecret;
        _token = token;
        _tokenSecret = tokenSecret;
        _requestUrl = requestUrl;
        _method = method;
    }

    private string BuildAuthHeader(string signature, string timestamp,
        string nonce)
    {
        var builder = new StringBuilder();
        builder.Append("OAuth ");
        builder.Append($"oauth_consumer_key=\"{_consumerKey}\",");
        builder.Append($"oauth_nonce=\"{nonce}\",");
        builder.Append($"oauth_signature=\"{signature}\",");
        builder.Append("oauth_signature_method=\"HMAC-SHA1\",");
        builder.Append($"oauth_timestamp=\"{timestamp}\",");
        builder.Append($"oauth_token=\"{_token}\",");
        builder.Append("oauth_version=\"1.0\"");
        return builder.ToString();
    }

    private void AddAuthParamters(List<WebParameter> parameter, string timestamp, string nonce)
    {
        var authParameters = new List<WebParameter>
        {
            new WebParameter("oauth_consumer_key", _consumerKey),
            new WebParameter("oauth_token", _token),
            new WebParameter("oauth_signature_method", "HMAC-SHA1"),
            new WebParameter("oauth_timestamp", timestamp),
            new WebParameter("oauth_nonce", nonce),
            new WebParameter("oauth_version", "1.0")
        };

        parameter.AddRange(authParameters);
    }

    private string GetSignature(string timestamp, string nonce, List<WebParameter>? queryParameters = null)
    {
        var parameters = queryParameters ?? new List<WebParameter>();
        AddAuthParamters(parameters, timestamp, nonce);
        var signatureBase = OAuthUtilities.ConcatenateRequestElements(_method.ToUpperInvariant(), _requestUrl, parameters);
        var signature = OAuthUtilities.GetSignature(signatureBase, _consumerSecret, _tokenSecret);
        return signature;
    }

    public string GetAuthorizationHeader(List<WebParameter>? queryParameters = null)
    {
        var timestamp = OAuthUtilities.GetTimestamp();
        var nonce = OAuthUtilities.GetNonce();
        var signature = GetSignature(timestamp, nonce, queryParameters);
        var header = BuildAuthHeader(signature, timestamp, nonce);
        return header;
    }
}
}
'@

    $oAuth = New-Object Bricklink.OAuthRequest($ConsumerKey, $ConsumerSecret, $Token, $TokenSecret, $Uri, $Method) 

    $oAuth.GetAuthorizationHeader()
    
}