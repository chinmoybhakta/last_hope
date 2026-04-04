// REPLACE THESE WITH YOUR ACTUAL CREDENTIALS FROM HUGGING FACE
const String hfClientId =
    'e341c214-22f8-4fe6-8ec2-64f09dc6b6ac'; // Get from huggingface.co/settings/applications
const String hfClientSecret =
    'oauth_app_secret_iLMAXjQIWVjBBIkpQWwZuPYqMznMsxYsnb'; // Only shown once when created!
const String hfRedirectUri = 'hf-flutter-auth://callback';

// Hugging Face OAuth endpoints [citation:10]
const String hfAuthUrl = 'https://huggingface.co/oauth/authorize';
const String hfTokenUrl = 'https://huggingface.co/oauth/token';
const String hfUserinfoUrl = 'https://huggingface.co/oauth/userinfo';
const String hfApiBase = 'https://huggingface.co/api';

// OAuth scopes needed [citation:1][citation:10]
const List<String> hfScopes = ['openid', 'profile', 'email', 'read-repos'];

// App storage keys
const String storageAccessTokenKey = 'hf_access_token';
const String storageRefreshTokenKey = 'hf_refresh_token';
const String storageUserInfoKey = 'hf_user_info';
const String storageModelsKey = 'downloaded_models';

// Model download settings
const String modelSearchQuery = 'GGUF';
const int maxModelsPerPage = 20;
