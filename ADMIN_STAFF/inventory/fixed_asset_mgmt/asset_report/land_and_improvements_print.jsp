<%@ page language="java" import="utility.*, inventory.InvFixedAssetMngt, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../..//css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../..//css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../..//jscript/common.js" ></script>
<script language="javascript"  src ="../../../..//jscript/date-picker.js" ></script>
<script>
function ReloadPage()
{
	document.form_.executeSearch.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
</script>
<%
	DBOperation dbOP = null;
	//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-FIXED_ASSET"),"0"));
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
								"Admin/staff-INVENTORY-INV_MAINT- View Inventory","land_and_improvements_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}
	
	InvFixedAssetMngt InvFAM = new InvFixedAssetMngt();
	Vector vRetResult = null;
	Vector vLands = null;
	Vector vImprovements = null;
	Vector vAdditional = null;
	String strErrMsg = null;
	
	vRetResult = InvFAM.searchLandAndImprove(dbOP,request);	
	String strTemp  = null;
	String strDateFr = WI.fillTextValue("date_fr");
	String strDateTo = WI.fillTextValue("date_to");
	int iCount = 0;
	int i = 0;
	double dLandTotal = 0d;
	double dLandImpTotal = 0d;
	double dTotalDepreciation = 0d;	
	double dNetTotal = 0d;
	
	if(vRetResult != null && vRetResult.size() > 0){
		vLands = (Vector) vRetResult.elementAt(0);
		vImprovements = (Vector) vRetResult.elementAt(1);
		vAdditional = (Vector) vRetResult.elementAt(2);	
	}else{
		strErrMsg = InvFAM.getErrMsg();
	}
	
%>
<body bgcolor="#FFFFFFF">
<form name="form_" action="land_and_improvements_print.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#000000"> 
      <td height="25" colspan="5" bgcolor="#FFFFFF">
          <div align="center"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
            <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></div>
	  </td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="29"><div align="center"><strong>LAND AND LAND IMPROVEMENTS</strong></div></td>
    </tr>
  </table>
	<%if(vLands != null && vLands.size() > 0){%>	
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4" ><strong><font size="2">A. LAND</font></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="6%" height="25" ><div align="center"><font size="1"><u>COUNT</u></font></div></td>
      <td width="63%" ><div align="center"><font size="1"><u>NAME/DESCRIPTION</u></font></div></td>
      <td width="17%" ><div align="center"><font size="1"><u>COST</u></font></div></td>
      <td width="19%" ><div align="center"><font size="1">
	  <%if(false){%>
	  <u>CURRENT ASSESSED VALUE </u>
	  <%}%>
	  </font></div></td>
    </tr>
    <%iCount = 1;
	for (i = 0;i < vLands.size(); i+=4,iCount++){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="20" ><div align="right"><%=iCount%>&nbsp;</div></td>
      <td ><%=(String)vLands.elementAt(i+1)%></td>
      <%
	  	strTemp = (String)vLands.elementAt(i+2);
		strTemp = WI.getStrValue(strTemp,"0");
		dLandTotal += Double.parseDouble(strTemp);
	  %>
      <td ><div align="right">&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
      <%
	  	strTemp = (String)vLands.elementAt(i+3);
	  %>
      <td ><div align="right">
	  <%if(false){%>
	  <%=CommonUtil.formatFloat(strTemp,true)%>
	  <%}%>
	  &nbsp;</div></td>
    </tr>
    <%}%>
    <tr bgcolor="#FFFFFF"> 
      <td height="21" ><div align="center"></div></td>
      <td >&nbsp;</td>
      <td ><hr size="1"></td>
      <td >&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="20" >&nbsp;</td>
      <td >Total as of <%=WI.formatDate(WI.fillTextValue("cut_off_date"),6)%></td>
      <td >&nbsp;</td>
      <td ><div align="right"><%=CommonUtil.formatFloat(dLandTotal,true)%>&nbsp;</div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="6%" height="20" >&nbsp;</td>
      <td width="63%" >&nbsp;</td>
      <td width="17%" >&nbsp;</td>
      <td width="19%" >&nbsp;</td>
    </tr>
  </table>
  <%}%>  
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" >
    <tr bgcolor="#FFFFFF"> 
      <td height="20" colspan="4" ><strong><font size="2">B. LAND IMPROVEMENTS</font></strong></td>
    </tr>
	<%if(vImprovements != null && vImprovements.size() > 0){%>
    <%iCount =1;
	
	for(i = 0;i<vImprovements.size();i+=6,iCount++){
		strTemp = ConversionTable.replaceString((String)vImprovements.elementAt(i+5),",","");
		strTemp = WI.getStrValue(strTemp,"0");		
		dTotalDepreciation += Double.parseDouble(strTemp);
		
	%>
    <tr bgcolor="#FFFFFF"> 
      <td width="5%" ><div align="center"><%=iCount%></div></td>
      <td width="61%" height="20" >&nbsp; <%=(String)vImprovements.elementAt(i+1)%></td>
      <%
	  	strTemp = (String)vImprovements.elementAt(i+2);
		strTemp = WI.getStrValue(strTemp,"0");
		dLandImpTotal += Double.parseDouble(strTemp);
	  %>
      <td width="16%" ><div align="right">&nbsp;<%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
      <%
	  	strTemp = (String)vImprovements.elementAt(i+3);
	  %>
      <td width="18%" ><div align="right"></div></td>
    </tr>
    <%}%>
    <tr bgcolor="#FFFFFF"> 
      <td height="10" >&nbsp;</td>
      <td height="10" >&nbsp;</td>
      <td height="10" valign="top" ><hr size="1"></td>
      <td height="10" >&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td >&nbsp;</td>
      <td height="25" >Total as of <%=WI.formatDate(WI.fillTextValue("cut_off_date"),6)%></td>
      <td ><div align="right"><%=CommonUtil.formatFloat(dLandImpTotal,true)%>&nbsp;</div></td>
      <td >&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td >&nbsp;</td>
      <td height="25" >Less: Accumulated Depreciation - Land Improvements</td>
      <td ><div align="right"><%=dTotalDepreciation%>&nbsp;</div></td>
      <td >&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="10" >&nbsp;</td>
      <td height="10" >&nbsp;</td>
      <td height="10" valign="top" ><hr size="1"></td>
      <td height="10" >&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td >&nbsp;</td>
      <td height="20" >Net Total as of <%=WI.formatDate(WI.fillTextValue("cut_off_date"),6)%></td>
	  <%
	  	dNetTotal = dLandImpTotal - dTotalDepreciation;
	  %>
      <td >&nbsp;</td>
      <td ><div align="right"><%=CommonUtil.formatFloat(dNetTotal,true)%></div></td>
    </tr>
    <%}%>
  </table>
  <%if(strDateFr != null && strDateTo != null){%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF"> 
      <td height="20" colspan="4" >&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4" ><strong><font size="2">C. ADD: <%=WI.formatDate(strDateFr,6)%> - <%=WI.formatDate(strDateTo,6)%>
        LAND ADDITIONS</font></strong></td>
    </tr>
	<%iCount =1;
	  dLandImpTotal = 0d;
	for(i = 0;i<vAdditional.size();i +=6,iCount++){%>	
    <tr bgcolor="#FFFFFF"> 
      <td width="5%" ><div align="right"><%=iCount%>&nbsp;</div></td>
      <td width="61%" height="20" >&nbsp; <%=(String)vAdditional.elementAt(i+1)%></td>
	  <%
	  	strTemp = (String)vAdditional.elementAt(i+2);
		strTemp = ConversionTable.replaceString(strTemp,",","");
		dLandImpTotal +=  Double.parseDouble(strTemp);
	  %>	  
      <td width="16%" height="20" ><div align="right"><%=CommonUtil.formatFloat(strTemp,true)%>&nbsp;</div></td>
      <td width="18%" height="20" >&nbsp;</td>
    </tr>
	<%}// end for loop%>
    <tr bgcolor="#FFFFFF"> 
      <td height="21" >&nbsp;</td>
      <td height="21" >&nbsp;</td>
      <td height="21" ><hr size="1"></td>
      <td height="21" >&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="20" >&nbsp;</td>
      <td height="20" >Total Addition to Land from <font size="2"><strong><font size="2"><%=WI.formatDate(strDateFr,6)%></font></strong> - <strong><font size="2"><%=WI.formatDate(strDateTo,6)%></font></strong></font></td>
      <td height="20" >&nbsp;</td>
      <td height="20" ><div align="right"><%=CommonUtil.formatFloat(dLandImpTotal,true)%>&nbsp;</div></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4" >&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="49%" height="10" >&nbsp;</td>
      <td width="17%" height="10" >&nbsp;</td>
      <td width="16%" height="10" >&nbsp;</td>
      <td width="18%" height="10" valign="top" ><hr size="1"></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="2" >TOTAL LAND &amp; LAND IMPROVEMENTS AS OF <font size="2"> 
        <strong><font size="2"><%=WI.formatDate(strDateTo,6)%></font></strong></font></td>
      <td >&nbsp;</td>
      <td ><div align="right"><%=CommonUtil.formatFloat(dLandTotal + dNetTotal + dLandImpTotal,true)%></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td >&nbsp;</td>
      <td ><hr size="2"></td>
    </tr>
  </table>
  <%}%>
  <input type="hidden" name="cut_off_date" value="<%=WI.fillTextValue("cut_off_date")%>">
  <input type="hidden" name="date_fr" value="<%=WI.fillTextValue("date_fr")%>">
  <input type="hidden" name="date_to" value="<%=WI.fillTextValue("date_to")%>">
  
<script language="JavaScript">
window.print();
</script>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>