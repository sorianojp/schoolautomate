<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	td{
		font-size: 11px;
		font-family: Verdana, Arial, Helvetica, sans-serif;
	}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="javascript">
function MapCOAAjax(strIsBlur) {
		var objCOA;
		objCOA=document.getElementById("coa_info");
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			document.form_.coa_code.value+"&coa_field_name=coa_code&is_blur="+strIsBlur;
		this.processRequest(strURL);
}
function COASelected(strAccountName) {
	document.getElementById("coa_info").innerHTML = "<font color='blue'>"+strAccountName+"</font>";
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.FeeExtraction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

//add security here.
	try	{
		dbOP = new DBOperation();
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
//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS".toUpperCase()),"0"));
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
FeeExtraction  FE = new FeeExtraction();
strTemp = WI.fillTextValue("page_action");

if (strTemp.equals("0")){
	if (FE.operateOnRPMapFee(dbOP, request,0) != null)
		strErrMsg = " Fee mapping removed successfully";
	else
		strErrMsg= FE.getErrMsg();
}
else if (strTemp.equals("1")){
	if (FE.operateOnRPMapFee(dbOP, request,1) != null)
		strErrMsg = " Fee mapping added successfully";
	else
		strErrMsg= FE.getErrMsg();
}

vRetResult = FE.operateOnRPMapFee(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = FE.getErrMsg();
//System.out.println(FE.operateOnRPMapFee(dbOP, request, 5));
%>
<form name="form_" action="./rec_projection_map.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="30" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          ACCOUNTS RECEIVABLE FEE LINKING PAGE :::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3"> &nbsp;&nbsp;&nbsp; <strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="13%">Fee Map Code </td>
      <td width="82%">
        <input name="fee_name_map" type="text" size="20" value="<%=WI.fillTextValue("fee_name_map")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';"> </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td> Fee Name </td>
      <td>
<%
	strTemp = " where not exists (select * " + 
		 " from  FA_FEE_HISTORY_RP_MAP where FEE_NAME_ORIG = fee_name) and is_del=0 order by fa_misc_fee.fee_name";
%>
	  <select name="fee_name_orig">
	  <%=dbOP.loadCombo("distinct fee_name"," fee_name", " from fa_misc_fee " + 
							strTemp,WI.fillTextValue("fee_name_orig"),false)%>
	  </select>	  </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Display Order </td>
      <td> <select name="map_order">
	  <%int iDefVal = Integer.parseInt(WI.getStrValue(WI.fillTextValue("map_order"), "1"));
	  for(int i = 0 ; i < 200; ++i) {
	  	if( i == iDefVal)
			strTemp = " selected";
		else	
			strTemp = "";
		%><option value="<%=i%>"<%=strTemp%>><%=i%></option>
	  <%}%>
  	  </select></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>

    <tr>
      <td  width="5%"height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td colspan="2">&nbsp;
<%if(iAccessLevel > 1){%>
        <input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="document.form_.page_action.value='1'">
        <%}//if iAccessLevel > 1%>      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5" bgcolor="#B9B292"><div align="center"><strong>ACCOUNTS RECEIVABLE MAPPING</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="4" class="thinborder" style="font-size:9px;">Total Mapped : <%=vRetResult.size()/4%></td>
    </tr>
    <tr>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">DISP ORDER </td>
      <td width="15%" height="25" class="thinborder" style="font-size:9px; font-weight:bold" align="center"> FEE TO DISPLAY </td>
      <td width="30%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">MISC/OTHER SCHOOL FEE </td>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">DELETE</td>
    </tr>
<%
String[] strBGColor = {"#B9E3D8","#79b3a8","#e0e0d0"};
int iColCount = 0;strTemp = "";
for (int i = 0; i < vRetResult.size() ; i+= 4) {
	if(strTemp.length() == 0)
		strTemp = (String)vRetResult.elementAt(i+3);
	else if(!strTemp.equals(vRetResult.elementAt(i+3)) ) {
		strTemp = (String)vRetResult.elementAt(i+3);
		++iColCount;
	}
	if(iColCount == 3)
		iColCount = 0;
%> 
    <tr bgcolor="<%=strBGColor[iColCount]%>">
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%> </td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%> </td>
      <td class="thinborder">
	 <% if (iAccessLevel == 2) {%> 
	 	<input type="submit" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.page_action.value='0';document.form_.info_index.value=<%=vRetResult.elementAt(i)%>">
	 <%}else{%> N/A <%}%>	  </td>
    </tr>
<%}%> 
  </table>
<%}%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>

  <!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="">
<input type="hidden" name="page_action" value="">


</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>