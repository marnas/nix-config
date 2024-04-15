{ appimageTools, fetchurl }:
appimageTools.wrapType2 { # or wrapType1
  name = "wowup"; 
  src = fetchurl { 
	url = "https://github.com/WowUp/WowUp/releases/download/v2.10.0/WowUp-2.10.0.AppImage";
    sha256 =  "sha256-zsPESxdEL5fxTq4CA/JcWIhVcBQHTjojGREGOCO6WYk=";
  };
}
