/// Centralized configuration for backend endpoints used by the app.
///
/// Sensitive values (e.g., API tokens) must **never** be shipped inside the
/// mobile client. Only expose public endpoints here; secure endpoints should be
/// proxied by the backend or protected by runtime auth flows.
const String speakersApiUrl = String.fromEnvironment(
  'SPEAKERS_API_URL',
  defaultValue:
      'https://segpr.saudiexim.gov.sa/backend/public/api/instructors?token=9f3a1d567b8c5e2hdbfhjvhf6a0b4c45sjdfh9d8e1f2a3b7c5d0e9f6a4b3c8d1e7f2a0c5b9d8e4f1a3b6c7d0e2f9a1b4c6d8e3f7a5bgfvld2c9d0e1f4a6b3c8d7f9a2b5c1e3d6f8advbhj0b4c7d9e2f1a5b3c8d0e6f7a9b1c4djgrvld2e5f0a6b3c9d7e1f2a5b4c8d6dgfbhje0f9a2b7c1',
);

const String speakersStorageBaseUrl = String.fromEnvironment(
  'SPEAKERS_STORAGE_BASE_URL',
  defaultValue: 'https://segpr.saudiexim.gov.sa/backend/public/storage',
);

// Public sponsors endpoint
const String sponsorsApiUrl = String.fromEnvironment(
  'SPONSORS_API_URL',
  defaultValue: 'https://segpr.saudiexim.gov.sa/backend/public/api/sponsors',
);

/// Reuse the same storage base for sponsor images
const String sponsorsStorageBaseUrl = String.fromEnvironment(
  'SPONSORS_STORAGE_BASE_URL',
  defaultValue: speakersStorageBaseUrl,
);
