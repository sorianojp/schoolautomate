<%@ page language="java" import="utility.*,inventory.InventoryMaintenance,java.util.Vector" %>
<%
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode ="";
		
boolean bolIsAUF = strSchCode.startsWith("AUF");
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
}
TABLE.thinborderALL {
    border-top: solid 1px #000000;
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;	
}
TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBottom {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBottomRight {
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderLeft {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderRight {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.NoBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script>
function PrintIssuance(strIssuanceNumber) {
	var pgLoc = "./issuance_details_print.jsp?issuance_number="+escape(strIssuanceNumber);
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>

<body>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;	
 		
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING-DELIVERY"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PURCHASING"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PURCHASING-DELIVERY-View delivery Status","issuance_details_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
		
%>	
<form name="form_" method="post" action="./issuance_main.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td width="2%" height="25">&nbsp;</td>
        <td width="35%" class="textbox_noborder">Enter PO/Delivery/Invoice/Issuance Number </td>
        <td width="73%"><input type="text" name="po_number" class="textbox" value="<%=WI.fillTextValue("po_number")%>"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  &nbsp;
	  <input type="image" src="../../../images/refresh.gif" border="0">
	  </td>
      </tr>
<%
String strSQLQuery = WI.fillTextValue("po_number");
strErrMsg = null; Vector vIssuance = new Vector();
if(strSQLQuery.length() > 0) {
	strSQLQuery = "select distinct issuance_number from PUR_DELIVERY "+
	"join pur_po_info on (pur_po_info.po_index = PUR_DELIVERY.po_index) "+
	"where issuance_number is not null and 	(DELIVERY_NO = '"+strSQLQuery +"' or INVOICE_NO = '"+strSQLQuery+ "' or po_number = '"+strSQLQuery+"') "+
	" and PUR_DELIVERY.is_valid = 1 order by issuance_number ";//System.out.println(strSQLQuery);
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) 
		vIssuance.addElement(rs.getString(1));//[0] issuance number.
	rs.close();
	if(vIssuance.size() ==0) 
		strErrMsg = "Issuance information not found.";
}
if(strErrMsg != null){%>
      <tr>
        <td height="20" colspan="3" style="font-size:14px; font-weight:bold; color:#FF0000"><%=strErrMsg%></td>
      </tr>
<%}if(vIssuance.size() > 0) {%>
      <tr>
        <td height="20" colspan="3"><!--<hr size="1" color="#0000FF">--> &nbsp;</td>
      </tr>
      <tr style="font-weight:bold">
        <td height="25">&nbsp;</td>
        <td class="thinborderBottom">Issuance Number </td>
        <td class="thinborderBottom">Print Issuance </td>
      </tr>
<%while(vIssuance.size() > 0) {%>
      <tr>
        <td height="25">&nbsp;</td>
        <td><%=vIssuance.elementAt(0)%></td>
        <td><a href="javascript:PrintIssuance('<%=vIssuance.remove(0)%>')"><img src="../../../images/print.gif" border="0"></a></td>
      </tr>
<%}%>


<%}%>
  </table>  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>