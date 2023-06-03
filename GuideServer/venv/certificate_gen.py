from OpenSSL import crypto, SSL

def cert_gen(
    emailAddress="2020e169@eng.jfn.ac.lk",
    commonName="com.eng.scavengersapp",
    countryName="LK",
    localityName="Ariviyal Nagar",
    stateOrProvinceName="Nothern",
    organizationName="PandaCodes",
    organizationUnitName="Scavengers",
    serialNumber=0,
    validityStartInSeconds=0,
    validityEndInSeconds=1*365*24*60*60,
    KEY_FILE = "private.key",
    CERT_FILE="selfsigned.crt"):
    #can look at generated file using openssl:
    #openssl x509 -inform pem -in selfsigned.crt -noout -text
    # create a key pair
    k = crypto.PKey()
    k.generate_key(crypto.TYPE_RSA, 4096)
    # create a self-signed cert
    cert = crypto.X509()
    cert.get_subject().C = countryName
    cert.get_subject().ST = stateOrProvinceName
    cert.get_subject().L = localityName
    cert.get_subject().O = organizationName
    cert.get_subject().OU = organizationUnitName
    cert.get_subject().CN = commonName
    cert.get_subject().emailAddress = emailAddress
    cert.set_serial_number(serialNumber)
    cert.gmtime_adj_notBefore(0)
    cert.gmtime_adj_notAfter(validityEndInSeconds)
    cert.set_issuer(cert.get_subject())
    cert.set_pubkey(k)
    cert.sign(k, 'sha512')
    with open('cert.pem', "wt") as f:
        f.write(crypto.dump_certificate(crypto.FILETYPE_PEM, cert).decode("utf-8"))
    with open('key.pem', "wt") as f:
        f.write(crypto.dump_privatekey(crypto.FILETYPE_PEM, k).decode("utf-8"))

cert_gen()