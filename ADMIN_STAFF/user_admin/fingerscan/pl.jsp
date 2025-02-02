<html>
<head>
<title>..</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css"></link>
</head>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function getPK(event) {
	if(event.keyCode == 13) {
		alert("I am here.");
	}
	
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector, search.FSProduct" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

	String strProductKey = null;
	String strProductID  = WI.fillTextValue("productID");
	//get the key here.. 
	if(strProductID.length() > 0) {
		if(strProductID.length() != 9)
			strErrMsg = "Wrong Product ID.";
		else {
			strTemp = String.valueOf(strProductID.charAt(2));
			if(!strTemp.equals("-"))
				strErrMsg = "Wrong Product ID.";
			else {
				strTemp =  String.valueOf(strProductID.charAt(6));
				if(!strTemp.equals("-"))
					strErrMsg = "Wrong Product ID.";
				else
					strProductKey = new FSProduct().getProductKey(strProductID);
			}
		}
	}
//strProductKey = new FSProduct().getProductKey(strProductID);
%>

<body>
<form action="pl.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="1" id="myADTable1">
    <tr> 
      <td height="25" colspan="3"><div align="center"><strong><font size="2">REGISTERED 
          FINGER SCANNER</font></strong></div></td>
    </tr>
    <tr> 
      <td width="3%">&nbsp;</td>
      <td height="28" colspan="2"><font size="2" color="#FF0000" ><strong><%=WI.getStrValue(strErrMsg)%></strong></font>&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="12%">Product ID:</td>
       <td width="85%" height="32"> <input type="text" name="productID" value="<%=WI.fillTextValue("productID")%>" class="textbox_noborder" >      </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Product Key:</td>
      <td height="27" style="font-weight:bold; font-size:16px; color:#FF0000"><%=strProductKey%></td>
    </tr>
  </table>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>