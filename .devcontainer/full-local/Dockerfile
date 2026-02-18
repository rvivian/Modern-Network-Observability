FROM mcr.microsoft.com/devcontainers/python:3.11-bookworm

# Place the certificate into the certificate directory
# The extra blank line at the end is required!
COPY <<EOF /usr/local/share/ca-certificates/root.crt
-----BEGIN CERTIFICATE-----
MIIFojCCA4qgAwIBAgIQEL95eYe9xIpJT8d3p2UhMTANBgkqhkiG9w0BAQsFADAe
MRwwGgYDVQQDExNDR1MgUHJpdmF0ZSBSb290IENBMB4XDTE2MDQyMDAzMzQ1NVoX
DTM2MDQyMDAzNDQ1NFowHjEcMBoGA1UEAxMTQ0dTIFByaXZhdGUgUm9vdCBDQTCC
AiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAJSPB1IKzR0TdEQhKHZV0ah8
6HpelUu1S/WUkmnmj6SGGCh5CsMe5uPKxj69K5HPNClbOFKqfKZ72BUq6jpWPuzi
MqLBA3+PknbMX1yTuJU7OFR5TsuPu0TxRYSHDrybxoweQtqiBudiQVO6kcLfSyqR
8je65hHBIluMtrU25cTbHCd9EFfidJwBMW5EwBy7/YjEsfReEyCrQtXMDbHGAacQ
lddMMYqB66qfSaYvYmoHXnWpGZZOrHUwK8/80L2ZbfFNrzeCNqtktICrhktU4r/T
0xYg/Spxc/ic4emM8Q8kKG1i4VD8YbrM5gqMAajzYI9+FEgH3wzrtC0P8YwEa122
BflEbImWgYGDpD7BzkYquLTjwyrATRucygDJF3NSVvcMbJeNuiBXQ8fj9nyZ2wZo
YhmWr/2QH6nRFFP3raubeuQA+BFK0ZtAfq0bSxj0/2HpHrtz0nl5oZ8o7E4BQfZh
TXfaN4q38mWs/JkWplueld4cfh+Z4z0dy7iQKyL7Wt+Jkt/c6Yb0TNxdtWxFgGRw
3uqfIE6v+MLPXBALRKRcxWZtkuWEfPFDmttmG1XnYaMlD9qQaPnu3CAlApHNonkg
o9l2bUq36aYmzKjspCinD0gpOBDr56K2nQsKYlr71OnPRNkx8JrYLP+hshz4Tlxx
0q/udHAwoO51SrrvytA5AgMBAAGjgdswgdgwCwYDVR0PBAQDAgGGMA8GA1UdEwEB
/wQFMAMBAf8wHQYDVR0OBBYEFKG/nRxQPfRvsGd18WnRI0/IrEgpMBAGCSsGAQQB
gjcVAQQDAgEAMIGGBgNVHSAEfzB9MHsGByoDBAEBAQEwcDA6BggrBgEFBQcCAjAu
HiwATABlAGcAYQBsACAAUABvAGwAaQBjAHkAIABTAHQAYQB0AGUAbQBlAG4AdDAy
BggrBgEFBQcCARYmaHR0cDovL3BraS5jaHVnYWNoZ292LmNvbS9wa2kvY3BzLnR4
dAAwDQYJKoZIhvcNAQELBQADggIBAHlEBSzI5odCa9oPwWmOoLnME0xDXTc3TfHO
8UCrEgWQ1Mu/CTau8b8blqoQzyOc+cXhR0H90++x3G77gZpydzFqm6AMXXSWwGZq
65hWOXYY1NpnUAJ3vQUFiQsuQEYuhEUXt6X9mXUYE5CIRNMNUps5/rYcMtAlyxUL
yl5I0AB4/JoiOB1+TO/mxbDjqBGWf7r7s9H7zACxhKbd//m5FH95AXhOKIwiGsvs
yo4fZE4qOC79qIvZirU/GkchAovd6jmb1CwIkG1fJyjFGV9OI79rJgkU9TY5Vkt/
ZB6ne6zDBrcReBmKReyrutkE/B5HJXBoakAKeLg0HfO9jDz0HtCQlbJD25yFGR/s
bLmCDcmodc/QW8m91J4/WhoEd8D5buWh7iZBV0Y3FXJC0s3omEgtsmao7i62Ul20
oYxExYc+xV1VYBmscRFq4oWxxucvUUX2M5oa1rCSBWwukQ/4XUYkHfWBapTGA5Ez
tBCxeDfsP+7imuM0Zch6oKe7TTKngy1Axpkxu3NiDrO7xKxMTM8E//YqrKn6RBlQ
rXLWFCo0kcThB7chweEp1EwVHRigozOkvu28zae/x5QOYUcy4vAlKdnLCPzbT1zc
uhzapwmdJ9flyBZjgwrWeHlL1abFB/+ogf9HwRyZ8a/K/jQohrx0OmHkYPxto3Dp
azg2fDLv
-----END CERTIFICATE-----

EOF

# Execute the command to update the ca certs
RUN update-ca-certificates

RUN echo "deb [trusted=yes] https://netdevops.fury.site/apt/ /" | \
    tee -a /etc/apt/sources.list.d/netdevops.list

# install containerlab and tools
RUN apt update && \
    apt install -y --no-install-recommends containerlab \
    btop \
    gh \
    iputils-ping \
    tcpdump \
    iproute2 \
    qemu-kvm \
    dnsutils \
    telnet

# Install gNMIc
RUN bash -c "$(curl -sL https://get-gnmic.openconfig.net)"

# Add empty docker config files to avoid clab warnings for root user
RUN mkdir -p /root/.docker && echo "{}" > /root/.docker/config.json

# Maintain SSH_AUTH_SOCK env var when using sudo
RUN mkdir -p /etc/sudoers.d && echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/ssh_auth_sock

# vscode user is created in the MS devcontainer image
USER vscode

ENV PATH="$PATH:/home/vscode/.local/bin"

# Create ssh key for vscode user to enable passwordless ssh to devices
RUN ssh-keygen -t ecdsa -b 256 -N "" -f ~/.ssh/id_ecdsa && \
    mkdir -p /home/vscode/.docker && \
    echo "{}" > /home/vscode/.docker/config.json

COPY --chown=vscode:vscode --chmod=700 . /netobs

RUN pip install --upgrade pip && \
    cd /netobs && \
    pip install . && \
    rm -r /netobs/*
