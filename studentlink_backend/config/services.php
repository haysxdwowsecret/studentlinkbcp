<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'mailgun' => [
        'domain' => env('MAILGUN_DOMAIN'),
        'secret' => env('MAILGUN_SECRET'),
        'endpoint' => env('MAILGUN_ENDPOINT', 'api.mailgun.net'),
        'scheme' => 'https',
    ],

    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],


    'firebase' => [
        'project_id' => env('FIREBASE_PROJECT_ID'),
        'private_key' => env('FIREBASE_PRIVATE_KEY'),
        'client_email' => env('FIREBASE_CLIENT_EMAIL'),
        'database_url' => env('FIREBASE_DATABASE_URL'),
        'storage_bucket' => env('FIREBASE_STORAGE_BUCKET'),
    ],

    'dialogflow' => [
        'project_id' => env('DIALOGFLOW_PROJECT_ID'),
        'private_key' => env('DIALOGFLOW_PRIVATE_KEY'),
        'client_email' => env('DIALOGFLOW_CLIENT_EMAIL'),
        'language_code' => env('DIALOGFLOW_LANGUAGE_CODE', 'en'),
        'session_id' => env('DIALOGFLOW_SESSION_ID', 'default-session'),
    ],

    'huggingface' => [
        'api_key' => env('HUGGINGFACE_API_KEY'),
        'base_url' => env('HUGGINGFACE_BASE_URL', 'https://api-inference.huggingface.co/models'),
        'model' => env('HUGGINGFACE_MODEL', 'microsoft/DialoGPT-medium'),
        'max_length' => env('HUGGINGFACE_MAX_LENGTH', 150),
        'temperature' => env('HUGGINGFACE_TEMPERATURE', 0.7),
        'timeout' => env('HUGGINGFACE_TIMEOUT', 30),
    ],

];
