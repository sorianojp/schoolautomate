<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	td{
		font-size: 11px;
		font-family: Verdana, Arial, Helvetica, sans-serif;
	}
</style>
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../Ajax/ajax.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../jscript/common.js"></script>
<script language="javascript">
function DeleteRecord(strInfoIndex){
	document.form_.page_action.value ="0";
	document.form_.info_index.value=strInfoIndex;
}
function MapCOAAjax(strIsBlur) {
		var objCOA;
		objCOA=document.getElementById("coa_info");
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			document.form_.coa_code.value+"&coa_field_name=coa_code&is_blur="+strIsBlur;
		this.processRequest(strURL);
}
function COASelected(strAccountName) {
	document.getElementById("coa_info").innerHTML = "<font color='blue'>"+strAccountName+"</font>";
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenance,java.util.Vector" %>
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
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strIsMiscFee = WI.fillTextValue("misc");

Vector vRetResult = null;
FAFeeMaintenance  fm = new FAFeeMaintenance();

if (WI.fillTextValue("page_action").equals("0")){
	if (fm.mapOtherSchFeeToCOA(dbOP, request,0) != null)
		strErrMsg = " Chart of Account mapping removed successfully";
	else
		strErrMsg= fm.getErrMsg();
}
else if (WI.fillTextValue("page_action").equals("1")){
	if (fm.mapOtherSchFeeToCOA(dbOP, request,1) != null)
		strErrMsg = " Chart of Account mapping added successfully";
	else
		strErrMsg= fm.getErrMsg();
}

vRetResult = fm.mapOtherSchFeeToCOA(dbOP, request, 4);

%>


<form name="form_" action="./fm_map_coa_oth_sch_fee.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="30" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          CHART OF ACCOUNT - FEE TYPE LINKING PAGE :::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4"> &nbsp;&nbsp;&nbsp; <strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="15%" valign="top">Account No. </td>
      <td width="24%" valign="top">
        <input name="coa_code" type="text" size="20" value="<%=WI.fillTextValue("coa_code")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';" onKeyUp="MapCOAAjax('0');"> </td>
      <td width="56%"><label id="coa_info" style="font-size:11px;"></label></td>
    </tr>
<%if(!strIsMiscFee.equals("2")){%>   
	<tr>
      <td height="24">&nbsp;</td>
      <td colspan="3" style="font-size:9px; font-weight:bold; color:#0000FF"> 
<%
strTemp = WI.fillTextValue("map_stat");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>	  
	  <input type="radio" name="map_stat" value="0" <%=strErrMsg%> onClick="document.form_.submit();"> Show ALL 
<%
if(strTemp.equals("1"))
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>	  
	  <input type="radio" name="map_stat" value="1" <%=strErrMsg%> onClick="document.form_.submit();"> Show Not yet Mapped 
<%
if(strTemp.equals("2"))
	strErrMsg = "checked";
else	
	strErrMsg = "";
%>	  
	  <input type="radio" name="map_stat" value="2" <%=strErrMsg%> onClick="document.form_.submit();"> Show only Mapped 
	  </td>
    </tr>
<%}%>
    <tr>
      <td height="24">&nbsp;</td>
      <td> Fee Name </td>
      <td  colspan="2">
	  
	  <%//System.out.println(strIsMiscFee);
	  if(strIsMiscFee.equals("2")){
		strTemp = " where is_valid = 1 and is_del = 0 and not exists (select * from fa_oth_sch_coa where fee_name = fa_oth_sch_fee.fee_name) order by fa_oth_sch_Fee.fee_name";
		%>
	  <select name="fee_name">
	  	<%=dbOP.loadCombo("distinct fa_oth_sch_Fee.fee_name"," fa_oth_sch_Fee.fee_name", " from fa_oth_sch_Fee " +strTemp,WI.fillTextValue("fee_name"),false)%>
	  </select>	  
	  <%}else{
	  	strTemp = WI.fillTextValue("map_stat");
		if(strTemp.equals("1"))
			strTemp = " and not exists (select * from fa_oth_sch_coa where fa_oth_sch_coa.fee_name = fa_misc_fee.fee_name) ";
		else if(strTemp.equals("2"))
			strTemp = " and exists (select * from fa_oth_sch_coa where fa_oth_sch_coa.fee_name = fa_misc_fee.fee_name) ";
	  	else	
			strTemp = "";
		strTemp = " where is_valid = 1 and is_del = 0 "+strTemp;
		if(WI.fillTextValue("misc").equals("1"))
			strTemp += " and misc_other_charge = 0 ";
		else
			strTemp += " and misc_other_charge = 1 ";	
		
		strTemp += " order by fa_misc_fee.fee_name";
	%>
		  <select name="fee_name">
		  <%=dbOP.loadCombo("distinct fa_misc_fee.fee_name"," fa_misc_fee.fee_name", " from fa_misc_fee " +strTemp,WI.fillTextValue("fee_name"),false)%>
		  </select>	  
<%}%>	  </td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Display Order </td>
      <td  colspan="2"> <select name="disp_order">
	  <%strTemp = "";
	  for(int i = 1 ; i < 100; ++i) {
	  	if( i == 10)
			strTemp = " selected";
		%><option value="<%=i%>"<%=strTemp%>><%=i%></option>
	  <%}%>
	  	</select>
	  (10 is by default, assign another if it must have a special disp. order)</td>
    </tr>
<!--
    <tr>
      <td height="24">&nbsp;</td>
      <td>Fund Type </td>
      <td  colspan="2">
	  <select name="fund_type">
	  	<option value="0">General</option>
<%strTemp = WI.fillTextValue("fund_type");
if(strTemp.equals("1"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>		<option value="1" <%=strErrMsg%>>Endowment</option>		
<%if(strTemp.equals("2"))
	strErrMsg = " selected";
else
	strErrMsg = "";
%>		<option value="2"<%=strErrMsg%>>FS(Faculty Staff)</option>		
	  </select>	  </td>
    </tr>
-->
	<input type="hidden" name="fund_type" value="0">
<%if(!strIsMiscFee.equals("2")){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Course</td>
      <td  colspan="2">
	  <select name="course_i">
	  <option value="">ALL</option>
	  <%=dbOP.loadCombo("course_index"," course_code, course_name", " from course_offered where is_valid = 1 and is_offered = 1 and is_visible = 1 order by course_code",WI.fillTextValue("course_i"),false)%>
	  </select>	  </td>
    </tr>
<%}%>
<%if(strIsMiscFee.equals("2")){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Fee Name to Display</td>
      <td  colspan="2"><input name="fee_disp" type="text" size="20" value="<%=WI.fillTextValue("fee_disp")%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white';"></td>
    </tr>
<%
strTemp = WI.fillTextValue("is_sundry");
if(request.getParameter("is_sundry") == null)
	strTemp = "0";

if(strTemp.equals("0")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
    <tr>
      <td height="24">&nbsp;</td>
      <td  colspan="3" style="font-size:9px; font-weight:bold; color:#0000FF">
	  <input type="radio" name="is_sundry" value="0" <%=strErrMsg%>> N/A
<%
if(strTemp.equals("1")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="is_sundry" value="1" <%=strErrMsg%>> Is Other Account
<%
if(strTemp.equals("2")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="is_sundry" value="2" <%=strErrMsg%>> Is Sundry Account	  </td>
    </tr>
<%}%>
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
      <td width="100%" height="25" bgcolor="#B9B292"><div align="center"><strong>CHART OF ACCOUNT EQUIVALENCE</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">DISP ORDER </td>
      <td width="10%" height="25" class="thinborder" style="font-size:9px; font-weight:bold" align="center"> ACCOUNT # </td>
      <td width="30%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">CHART OF ACCOUNT NAME </td>
      <td width="30%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">OTHER SCHOOL FEE </td>
<%if(!strIsMiscFee.equals("2")){%>
      <td width="20%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">COURSE</td>
<%}else{%>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">ACCOUNT TYPE</td>
      <td width="20%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">FEE NAME TO DISPLAY </td>
<%}%>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">DELETE</td>

<%
String[] astrConvertFundType = {"General","Endowment","FS"}; 
String[] astrAccountType = {"&nbsp;","O","S"}; 

for (int i = 0; i < vRetResult.size() ; i+= 11) {%> 
    </tr>
    <tr>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%> </td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%> </td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%> </td>
<%if(!strIsMiscFee.equals("2")){%>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+7), "ALL")%></td>
<%}else{%>
      <td class="thinborder" align="center" style="font-weight:bold"><%=astrAccountType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+9), "0"))]%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+10), "&nbsp;")%></td>
<%}%>
      <td class="thinborder">
	 <% if (iAccessLevel == 2) {%> 
	 	<input type="submit" name="122" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;"
		 onClick="document.form_.page_action.value='0';document.form_.info_index.value=<%=vRetResult.elementAt(i + 6)%>">
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
<input type="hidden" name="misc" value="<%=WI.fillTextValue("misc")%>">

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>