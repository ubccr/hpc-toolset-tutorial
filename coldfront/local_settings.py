"""
Local ColdFront settings

Here you can define custom database settings, add authentication backends,
configure logging, and ColdFront plugins.
"""
#------------------------------------------------------------------------------
# Secret Key -- Generate new key using: https://www.miniwebtool.com/django-secret-key-generator/
# and replace
#------------------------------------------------------------------------------
SECRET_KEY = '4^17+^=y5-&yx)uf(b%!bd_@vce&0p42%f@yf41l)5%9h1$q00'

#------------------------------------------------------------------------------
# Enable debugging. WARNING: These should be set to False in production
#------------------------------------------------------------------------------
DEBUG = True
DEVELOP = True

if DEBUG is False and SECRET_KEY is 'vtri&lztlbinerr4+yg1yzm23ez@+ub6=4*63z1%d!)fg(g4x$':
    from django.core.exceptions import ImproperlyConfigured
    raise ImproperlyConfigured("The SECRET_KEY setting is using the preset value. Please update it!")

#------------------------------------------------------------------------------
# Session settings
#------------------------------------------------------------------------------
# This should be set to True in production when using HTTPS
SESSION_COOKIE_SECURE = False

#------------------------------------------------------------------------------
# General Center Information
#------------------------------------------------------------------------------
CENTER_NAME = 'HPC Resources'
# CENTER_HELP_URL = 'http://localhost/help'
# CENTER_PROJECT_RENEWAL_HELP_URL = 'http://localhost/help'
# CENTER_BASE_URL = 'https://coldfront.io'

#------------------------------------------------------------------------------
# Locale settings
#------------------------------------------------------------------------------
# https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'America/New_York'

#------------------------------------------------------------------------------
# Logging
#------------------------------------------------------------------------------
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
        # 'file': {
        #     'class': 'logging.FileHandler',
        #     'filename': '/tmp/debug.log',
        # },
    },
    'loggers': {
        'django_auth_ldap': {
            'level': 'WARN',
            # 'handlers': ['console', 'file'],
            'handlers': ['console', ],
        },
        'django': {
            'handlers': ['console'],
            'level': 'INFO',
        },
    },
}

#------------------------------------------------------------------------------
# Advanced ColdFront configurations
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Enable Project Review
#------------------------------------------------------------------------------
PROJECT_ENABLE_PROJECT_REVIEW = True

#------------------------------------------------------------------------------
# Allocation related
#------------------------------------------------------------------------------
ALLOCATION_ENABLE_ALLOCATION_RENEWAL = True
ALLOCATION_FUNCS_ON_EXPIRE = ['coldfront.core.allocation.utils.test_allocation_function', ]
ALLOCATION_DEFAULT_ALLOCATION_LENGTH = 365 # DAYS


#------------------------------------------------------------------------------
# Custom Database settings
#------------------------------------------------------------------------------
# NOTE: For mysql you need to: pip install mysqlclient
#
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'coldfront',
        'USER': 'coldfrontapp',
        'PASSWORD': '9obCuAphabeg',
        'HOST': 'mysql',
        'PORT': '',
    },
}
#
# NOTE: For postgresql you need to: pip install psycopg2
#
# DATABASES = {
#     'default': {
#         'ENGINE': 'django.db.backends.postgresql_psycopg2',
#         'NAME': 'coldfront',
#         'USER': '',
#         'PASSWORD': '',
#         'HOST': 'localhost',
#         'PORT': '5432',
#     },
# }

EXTRA_APPS = []
EXTRA_MIDDLEWARE = []
EXTRA_AUTHENTICATION_BACKENDS = []
LOCAL_SETTINGS_EXPORT = []


#------------------------------------------------------------------------------
# Email/Notification settings
#------------------------------------------------------------------------------
# EMAIL_ENABLED = True
# EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
# EMAIL_HOST = 'localhost'
# EMAIL_PORT = 25
# EMAIL_HOST_USER = ''
# EMAIL_HOST_PASSWORD = ''
# EMAIL_USE_TLS = False
# EMAIL_TIMEOUT = 3
# EMAIL_SUBJECT_PREFIX = '[ColdFront]'
# EMAIL_ADMIN_LIST = ['admin@localhost']
# EMAIL_SENDER = 'coldfront@localhost'
# EMAIL_TICKET_SYSTEM_ADDRESS = 'help@localhost'
# EMAIL_DIRECTOR_EMAIL_ADDRESS = 'director@localhost'
# EMAIL_PROJECT_REVIEW_CONTACT = 'review@localhost'
# EMAIL_DEVELOPMENT_EMAIL_LIST = ['dev1@localhost', 'dev2@localhost']
# EMAIL_OPT_OUT_INSTRUCTION_URL = 'http://localhost/optout'
# EMAIL_ALLOCATION_EXPIRING_NOTIFICATION_DAYS = [7, 14, 30]
# EMAIL_SIGNATURE = """
# HPC Resources
# http://localhost
# """


#------------------------------------------------------------------------------
# Enable administrators to login as other users
#------------------------------------------------------------------------------
EXTRA_AUTHENTICATION_BACKENDS += ['django_su.backends.SuBackend',]

#------------------------------------------------------------------------------
# Example config for OAuth2/OpenID Authentication. This configuration 
# authenticates against Dex (provided in the ondemand container). 
#------------------------------------------------------------------------------
EXTRA_APPS += [
    'mozilla_django_oidc',
]

EXTRA_AUTHENTICATION_BACKENDS += [
    'mozilla_django_oidc.auth.OIDCAuthenticationBackend',
]

EXTRA_MIDDLEWARE += [
    'mozilla_django_oidc.middleware.SessionRefresh',
]

OIDC_OP_JWKS_ENDPOINT = "https://ondemand:5554/keys"
OIDC_RP_SIGN_ALGO = 'RS256'
OIDC_RP_CLIENT_ID = 'coldfront'
OIDC_RP_CLIENT_SECRET = 'fY8MwkYymslM5aKTllcDTKUNgTmYgPQDwQ1GSSwTWX24Qsh4D1hbyDuyK7QnbHj3'
OIDC_OP_AUTHORIZATION_ENDPOINT = "https://localhost:5554/auth"
OIDC_OP_TOKEN_ENDPOINT = "https://ondemand:5554/token"
OIDC_OP_USER_ENDPOINT = "https://ondemand:5554/userinfo"
OIDC_VERIFY_SSL = False
OIDC_RENEW_ID_TOKEN_EXPIRY_SECONDS = 60 * 60

def generate_username(email):
    # XXX This is a simple example to generate usernames. Do not use in production
    return email.split('@')[0]

OIDC_USERNAME_ALGO=generate_username

#------------------------------------------------------------------------------
# Example config for enabling LDAP user search (connects to the LDAP container)
#------------------------------------------------------------------------------
LDAP_SERVER_URI = 'ldap://ldap'
LDAP_USER_SEARCH_BASE = 'ou=People,dc=example,dc=org'
LDAP_BIND_DN = 'cn=admin,dc=example,dc=org'
LDAP_BIND_PASSWORD = 'admin'
ADDITIONAL_USER_SEARCH_CLASSES = ['coldfront.plugins.ldap_user_search.utils.LDAPUserSearch',]

# ------------------------------------------------------------------------------
# Enable invoice functionality
# ------------------------------------------------------------------------------
# INVOICE_ENABLED = True
# INVOICE_DEFAULT_STATUS = 'New'  # Override default 'Pending Payment' status

# ------------------------------------------------------------------------------
# Allow user to select account name for allocation
# ------------------------------------------------------------------------------
ALLOCATION_ACCOUNT_ENABLED = False
# ALLOCATION_ACCOUNT_MAPPING = {
#     'University HPC': 'slurm_account_name',
#     'University Cloud': 'Cloud Account Name',
# }

LOCAL_SETTINGS_EXPORT += [
    'ALLOCATION_ACCOUNT_ENABLED'
]


#===============================================================================
# ColdFront Plugin Settings
#===============================================================================

#------------------------------------------------------------------------------
# Enable iquota reporting
#------------------------------------------------------------------------------
# EXTRA_APPS += [
#     'coldfront.plugins.iquota'
# ]
#
# IQUOTA_KEYTAB = '/path/to/user.keytab'
# IQUOTA_CA_CERT = '/etc/ipa/ca.crt'
# IQUOTA_API_HOST = 'localhost'
# IQUOTA_API_PORT = '8080'
# IQUOTA_USER_PATH = '/ifs/user'
# IQUOTA_GROUP_PATH = '/ifs/projects'

#------------------------------------------------------------------------------
# Enable system monitor reporting
#------------------------------------------------------------------------------
# EXTRA_APPS += [
#     'coldfront.plugins.system_monitor'
# ]
# SYSTEM_MONITOR_PANEL_TITLE = 'HPC Cluster Status'
# SYSTEM_MONITOR_ENDPOINT = 'http://localhost/status/status.html'
# SYSTEM_MONITOR_DISPLAY_MORE_STATUS_INFO_LINK = 'http://localhost/status'
# SYSTEM_MONITOR_DISPLAY_XDMOD_LINK = 'https://localhost/xdmod'


#------------------------------------------------------------------------------
# Enable FreeIPA app for updating group membership and user search
#------------------------------------------------------------------------------
# EXTRA_APPS += [
#     'coldfront.plugins.freeipa',
# ]
# FREEIPA_KTNAME = '/path/to/user.keytab'
# FREEIPA_SERVER = 'freeipa.localhost.localdomain'
# FREEIPA_USER_SEARCH_BASE = 'cn=users,cn=accounts,dc=example,dc=edu'
# FREEIPA_ENABLE_SIGNALS = False
# ADDITIONAL_USER_SEARCH_CLASSES = ['coldfront.plugins.freeipa.search.LDAPUserSearch',]

#------------------------------------------------------------------------------
# Enable Mokey/Hydra OpenID Connect Authentication Backend
#------------------------------------------------------------------------------
# EXTRA_APPS += [
#     'mozilla_django_oidc',
#     'coldfront.plugins.mokey_oidc',
# ]
#
# EXTRA_AUTHENTICATION_BACKENDS += [
#     'coldfront.plugins.mokey_oidc.auth.OIDCMokeyAuthenticationBackend',
# ]
#
# EXTRA_MIDDLEWARE += [
#     'mozilla_django_oidc.middleware.SessionRefresh',
# ]
#
# OIDC_OP_JWKS_ENDPOINT = "https://localhost/hydra/.well-known/jwks.json"
# OIDC_RP_SIGN_ALGO = 'RS256'
# OIDC_RP_CLIENT_ID = ''
# OIDC_RP_CLIENT_SECRET = ''
# OIDC_OP_AUTHORIZATION_ENDPOINT = "https://localhost/hydra/oauth2/auth"
# OIDC_OP_TOKEN_ENDPOINT = "https://localhost/hydra/oauth2/token"
# OIDC_OP_USER_ENDPOINT = "https://localhost/hydra/userinfo"
# OIDC_VERIFY_SSL = True
# OIDC_RENEW_ID_TOKEN_EXPIRY_SECONDS = 60 * 60

#------------------------------------------------------------------------------
# Enable Slurm support
#------------------------------------------------------------------------------
EXTRA_APPS += [
    'coldfront.plugins.slurm',
]
SLURM_IGNORE_USERS = ['root']
SLURM_SACCTMGR_PATH = '/usr/bin/sacctmgr'

#------------------------------------------------------------------------------
# Enable XDMoD support
#------------------------------------------------------------------------------
# EXTRA_APPS += [
#     'coldfront.plugins.xdmod',
# ]

# XDMOD_API_URL = 'http://localhost'
