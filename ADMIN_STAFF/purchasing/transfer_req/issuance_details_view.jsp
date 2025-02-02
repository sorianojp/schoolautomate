<%@ page language="java" import="utility.*,inventory.InventoryMaintenance,java.util.Vector" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPage(){
	document.form_.printPage.value = "1";
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72">
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;	
//add security here.
   if(WI.fillTextValue("printPage").equals("1")){%>
		<jsp:forward page="issuance_details_print.jsp"/>
	  <%}
		
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
								"Admin/staff-PURCHASING-DELIVERY-View delivery Status","issuance_details_view.jsp");
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
	String strSchCode = dbOP.getSchoolIndex();	
 	InventoryMaintenance invMaint = new InventoryMaintenance();	

	Vector vIssuanceInfo = null;
	Vector vRetResult = null;

 	int iCount = 1;
	int iSearchResult = 0;
	int iDefault = 0;
	
	vRetResult = invMaint.getIssuanceInfo(dbOP,request, WI.fillTextValue("issuance_index"),false);
 	if(vRetResult == null)
		strErrMsg = invMaint.getErrMsg();
	else{
		iSearchResult = invMaint.getSearchCount();
		vIssuanceInfo = (Vector) vRetResult.elementAt(0);
	}

%>	
<form name="form_" method="post" action="./issuance_details_view.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF"><strong>:::: 
      ISSUANCE - ITEM ISSUANCE PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <%if(vIssuanceInfo != null && vIssuanceInfo.size() > 1){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td height="26" colspan="5" align="center"><strong><font color="#FFFFFF">ISSUANCE INFORMATION </font></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>ISSUANCE # </td>
      <td><strong><%=(String)vIssuanceInfo.elementAt(0)%> </strong></td>
      <td>ISSUE DATE: </td>
      <td><strong><%=(String)vIssuanceInfo.elementAt(1)%></strong></td>
    </tr>
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="14%">RECEIVED BY: </td>
      <td width="33%"><strong><%=(String)vIssuanceInfo.elementAt(2)%></strong></td>
      <td width="14%">PO Number </td>
      <td width="36%"><strong><%=(String)vIssuanceInfo.elementAt(4)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Prepared By : </td>
			<%
				strTemp = WI.fillTextValue("prepared_by");
			%>
      <td><input type="text" name="prepared_by" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Inspected by : </td>
			<%
				strTemp = WI.fillTextValue("inspected_by");
			%>			
      <td><input type="text" name="inspected_by" class="textbox" value="<%=strTemp%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  		<tr>
			<%
				if(WI.fillTextValue("is_pre_printed").equals("1"))
					strTemp = " checked";
				else
					strTemp = " ";
			%>
			<td width="50%">&nbsp;</td>
		  <td width="50%" align="right">Items per page</font> 
          <select name="num_rows">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"15"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"> </a> <font size="1">click to print</font> </td>
 		</tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="2" align="center" bgcolor="#B9B292" class="thinborder"><font color="#FFFFFF"><strong>LIST 
      OF ISSUED ITEM(S)</strong></font></td>
    </tr>
    <tr>
      <td width="70%" height="25" align="center" class="thinborder"><strong>ITEM / PARTICULARS 
      / DESCRIPTION</strong></td>
      <td width="30%" align="center" class="thinborder"><strong>QTY UNIT</strong></td>
    </tr>
    <%iCount = 1;
	for(int i = 1;i < vRetResult.size();i+=6,++iCount){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"(",")","")%></td>
      <td align="right" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%>&nbsp;<%=(String)vRetResult.elementAt(i+3)%>&nbsp;</td>
     </tr>
    <%}%>
  </table>
  <%}}%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td width="4%" height="25" colspan="8"></td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
	<input type="hidden" name="issuance_index" value="<%=WI.fillTextValue("issuance_index")%>">	
  <input type="hidden" name="printPage" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>