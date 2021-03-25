"""
Local ColdFront settings

Here you can define advanced custom settings
"""

def generate_username(email):
    # XXX This is a simple example to generate usernames. Do not use in production
    return email.split('@')[0]

OIDC_USERNAME_ALGO=generate_username
