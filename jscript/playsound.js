
ver=parseInt(navigator.appVersion)
ie4=(ver>3  && navigator.appName!="Netscape")?1:0
ns4=(ver>3  && navigator.appName=="Netscape")?1:0
ns3=(ver==3 && navigator.appName=="Netscape")?1:0

function playSound() {
 if (ie4) document.all['BGSOUND_ID'].src='error_attendance.wav';
 if ((ns4||ns3)
  && navigator.javaEnabled()
  && navigator.mimeTypes['audio/x-midi']
  && self.document.PLAYSOUND.IsReady()
 )
 {
  self.document.PLAYSOUND.play()
 }
}

function stopSound() {
 if (ie4) document.all['BGSOUND_ID'].src='jsilence.mid';
 if ((ns4||ns3)
  && navigator.javaEnabled()
  && navigator.mimeTypes['audio/x-midi']
 )
 {
  self.document.PLAYSOUND.stop()
 }
}
