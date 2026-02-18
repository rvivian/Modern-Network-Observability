ARG TELEGRAF_IMAGE=docker.io/telegraf:1.31

FROM $TELEGRAF_IMAGE

RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    ca-certificates \
    curl \
    git \
    && apt-get clean

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

# Download and install Miniconda
# RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py312_24.5.0-0-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

# Add Miniconda to PATH
ENV PATH=/opt/conda/bin:$PATH

# Verify the installation
RUN conda --version

RUN pip install --upgrade pip && \
    pip --no-cache-dir install netmiko jmespath rich ttp

# For TTP...
RUN chown -R telegraf:telegraf /opt/conda/lib/python3.12/site-packages/ttp