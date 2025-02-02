<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == '0') {
		if(!confirm('Click Ok to confirm delete.'))
			return;
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
}
function ReloadPage() {
	document.form_.page_action.value = "";
	document.form_.submit();
}

///for ajax.. 
var objCOA;
function MapCOAAjax(strCoaFieldName, strParticularFieldName) {
		objCOA=document.getElementById(strParticularFieldName);
		if(strParticularFieldName == 'coa_info_d')
			document.getElementById('coa_info_c').innerHTML='';
		else
			document.getElementById('coa_info_d').innerHTML='';
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var objCOAInput;
		eval('objCOAInput=document.form_.'+strCoaFieldName);
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=1&coa_entered="+
			objCOAInput.value+"&coa_field_name="+strCoaFieldName;
		this.processRequest(strURL);
}
function COASelected(strAccountName, objParticular) {
	//objCOA.innerHTML = "<b>"+strAccountName+"</b>";
	objCOA.innerHTML = "";
}
//get the ar information.
function fillupARInfo() {
	var strValues = "";
	if(document.form_.yr_level)
		strValues="&yr_level="+document.form_.yr_level[document.form_.yr_level.selectedIndex].value;
	if(document.form_.college)
		strValues="&college="+document.form_.college[document.form_.college.selectedIndex].value;
	if(document.form_.course_index)
		strValues="&course_index="+document.form_.course_index[document.form_.course_index.selectedIndex].value;

		objCOA=document.form_._coa;

		this.InitXmlHttpObject(objCOA, 1);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=503"+strValues;
		this.processRequest(strURL);

}
</script>

<body bgcolor="#D2AE72" onLoad="fillupARInfo();">
<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","map_misc_oc.jsp");
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
//fee name is empty if handson -- 
boolean bolIsHandsOn = WI.fillTextValue("is_oc").equals("2");

Administration adm = new Administration();
Vector vRetResult = null;
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(adm.operateOnMiscOCMappingNEW(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strErrMsg = "Operation successful.";

	}
}
if(WI.fillTextValue("fee_name_sa").length() > 0 || WI.fillTextValue("view_all").length() > 0 || bolIsHandsOn) {
	vRetResult = adm.operateOnMiscOCMappingNEW(dbOP, request, 3);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = adm.getErrMsg();
}

//0 = per course, 1 = per college.
boolean bolFatalErr = false;
String strMapRef = "select prop_val from read_property_file where prop_name = 'AR_MAPPING_PERCOLLEGE'";
strMapRef = dbOP.getResultOfAQuery(strMapRef, 0);
if(strMapRef == null) {
	strErrMsg = "Please set MAP PER COLLEGE or MAP PER COURSE information.";
	bolFatalErr = true;
}

Vector vFeeList     = adm.operateOnMiscOCMappingNEW(dbOP, request, 5);
if(vFeeList == null)//nothing to map.
	vFeeList = new Vector();
//System.out.println(adm.getErrMsg());

    boolean bolIsBasic = false;
	if(WI.fillTextValue("is_basic").length() > 0) 
		bolIsBasic = true;

boolean bolIsOC = WI.fillTextValue("is_oc").equals("1");

%>
<form action="./map_misc_oc.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: MAP <%if(bolIsOC){%>OTHER CHARGES<%}else{%>MISCELLANEOUS FEE<%}%> ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2" style="font-weight:bold; font-size:11px; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="checked" <%=WI.fillTextValue("is_basic")%> onClick="ReloadPage()"> Link Grade School	  </td>
      <td colspan="2" style="font-size:11px;" align="right">
	  <a href="../map_coa_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a> Go Back To Main</td>
    </tr>
<%if(!bolIsHandsOn){%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td colspan="4">
		  <input type="checkbox" name="search_con" value="checked" onClick="document.form_.page_action.value='';document.form_.submit()" <%=WI.fillTextValue("search_con")%>>
		  Show Fee Having all  Mapped &nbsp;&nbsp;&nbsp;&nbsp;
		  <input type="checkbox" name="view_all" value="checked" onClick="document.form_.page_action.value='';document.form_.submit()" <%=WI.fillTextValue("view_all")%>>
		  Show all mapped in one List	  </td>
		</tr>
	<%if(WI.fillTextValue("is_oc").equals("1")) {%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td colspan="4" style="font-size:11px; font-weight:bold; color:#0000FF"><input type="checkbox" name="copy_all"> Create for all Courses </td>
		</tr>
	<%}%>
		<tr>
		  <td width="2%" height="25">&nbsp;</td>
		  <td width="16%">Fee Name (SA) </td>
		  <td colspan="3">
			<select name="fee_name_sa" onChange="document.form_.page_action.value='';document.form_.fee_name_map.value=document.form_.fee_name_sa[document.form_.fee_name_sa.selectedIndex].value;document.form_.submit()">
			<option value=""></option>
	<%
	strTemp = WI.fillTextValue("fee_name_sa");
	for(int i = 0; i < vFeeList.size(); ++i) {
		if(strTemp.equals(vFeeList.elementAt(i)))
			strErrMsg = " selected";
		else
			strErrMsg = "";
		%>
		<option value="<%=vFeeList.elementAt(i)%>" <%=strErrMsg%>><%=vFeeList.elementAt(i)%></option>
		
	<%}%>
			</select>	  </td>
		</tr>
<%}//do not show if bolIsHandsOn
strTemp = WI.getInsertValueForDB(strTemp, true, null);
if(bolIsBasic) {%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>Grade Level</td>
      <td colspan="3">
<%
	strTemp = " where not exists (select * from FA_COLLEGE_MISCOC where yr_level = G_LEVEL "+
				" and FEE_NAME_SA = "+strTemp+" and is_oc = "+WI.fillTextValue("is_oc")+") order by G_LEVEL";
	if(bolIsHandsOn) {
	strTemp = " where not exists (select * from FA_COLLEGE_MISCOC where yr_level = G_LEVEL "+
				" and FEE_NAME_SA is null and is_oc = "+WI.fillTextValue("is_oc")+") order by G_LEVEL";
	}
%>
	  	  <select name="yr_level" onChange="fillupARInfo()">
          <%=dbOP.loadCombo("G_LEVEL","EDU_LEVEL_NAME +' - '+ LEVEL_NAME"," from BED_LEVEL_INFO "+strTemp,WI.fillTextValue("yr_level"),false)%>
      </select>	  </td>
    </tr>
<%}else if(strMapRef.equals("1")){%>
    <tr>
      <td height="26">&nbsp;</td>
      <td>College</td>
      <td colspan="3">
<%
	strTemp = " where not exists (select * from FA_COLLEGE_MISCOC where college_index = c_index "+
				" and FEE_NAME_SA = "+strTemp+" and is_oc = "+WI.fillTextValue("is_oc")+") and is_del=0 order by c_code";
	if(bolIsHandsOn) {
			strTemp = " where not exists (select * from FA_COLLEGE_MISCOC where college_index = c_index "+
				" and FEE_NAME_SA is null and is_oc = "+WI.fillTextValue("is_oc")+") and is_del=0 order by c_code";
	}

%>
	  <select name="college" onChange="fillupARInfo()">
	  <%=dbOP.loadCombo("c_index","c_code", " from college " + strTemp,WI.fillTextValue("college"),false)%>
      </select>  	  </td>
    </tr>
<%}else{%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Course </td>
      <td colspan="3" style="font-size:11px;">
<%
	strTemp = " where not exists (select * from FA_COLLEGE_MISCOC where course_i = course_index"+
				" and FEE_NAME_SA = "+strTemp+" and is_oc = "+WI.fillTextValue("is_oc")+") and is_del=0 and is_offered = 1";
	if(bolIsHandsOn) {
		strTemp = " where not exists (select * from FA_COLLEGE_MISCOC where course_i = course_index"+
				" and FEE_NAME_SA is null and is_oc = "+WI.fillTextValue("is_oc")+") and is_del=0 and is_offered = 1";
	}
%>
	  <select name="course_index" style="width:400px" onChange="fillupARInfo()">
	  <%=dbOP.loadCombo("course_index","course_code, course_name", " from course_offered " + strTemp,
	  		WI.fillTextValue("course_index"),false)%>
      </select>
	    </td>
    </tr>
<%}
if(!bolIsHandsOn){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Name (MAPPED) </td>
      <td colspan="3">
	  <input type="text" name="fee_name_map" size="60" value="<%=WI.fillTextValue("fee_name_map")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>COA Debit </td>
      <td colspan="3">
		<input name="_coa" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("_coa")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('_coa', 'coa_info_d');" autocomplete="off">	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>COA Credit </td>
      <td colspan="3"><input name="_coa2" type="text" size="26" maxlength="32" value="<%=WI.fillTextValue("_coa2")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onkeyUP="MapCOAAjax('_coa2', 'coa_info_c');" autocomplete="off"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Display Order </td>
      <td colspan="3">
	  <select name="disp_order">
<%
strTemp = WI.fillTextValue("disp_order");
int iDef = 0;
if(strTemp.length() > 0)
	iDef = Integer.parseInt(strTemp);
	
	for(int i =1; i < 501; ++i) {
		if(iDef == i)
			strTemp = " selected";
		else	
			strTemp = "";
		%><option value="<%=i%>" <%=strTemp%>><%=i%></option>
		<%}%>
		</select>	  </td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td colspan="3"><label id="coa_info_d" style="font-size:11px; position:absolute"></label><label id="coa_info_c" style="font-size:11px; position:absolute"></label></td>
    </tr>
    <tr>
      <td height="45">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td width="32%" align="center"><input type="submit" name="122" value="Add Mapping" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='1';"></td>
      <td width="40%" align="center">&nbsp;</td>
      <td width="10%" align="center">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr bgcolor="#CCCCCC" style="font-weight:bold">
		<td height="22" class="thinborder" width="4%">Order#</td>
		<td width="20%" class="thinborder"> Name (SA) </td>
		<td width="20%" class="thinborder">MAP Name </td>
		<td width="15%" align="center" class="thinborder">DEBIT Account </td>
        <td width="15%" align="center" class="thinborder">CREDIT Account </td>
<%if(bolIsBasic){%>
		<td width="10%" class="thinborder">Grade Level</td>
<%}else if(strMapRef.equals("1")){%>
		<td width="10%" class="thinborder">College</td>
<%}else{%>
	    <td width="10%" class="thinborder">Course</td>
<%}%>
	    <td width="5%" align="center" class="thinborder">Delete</td>
  	</tr>
<%
String strBGColor = "";
String strFeeNameSA = "";
for(int i =0; i < vRetResult.size(); i += 13) {
	if(!bolIsHandsOn){
		if(!strFeeNameSA.equals(vRetResult.elementAt(i + 9))) {
			strFeeNameSA = (String)vRetResult.elementAt(i + 9);
			if(strBGColor.equals("#66CC99"))
				strBGColor = "#99CCCC";
			else	
				strBGColor = "#66CC99";
		}
	}
		%>
  	<tr bgcolor="<%=strBGColor%>">
		<td height="24" class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 9),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 10),"&nbsp;")%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i + 1)%><br><%=vRetResult.elementAt(i + 2)%></td>
        <td class="thinborder"><%=vRetResult.elementAt(i + 11)%><br><%=vRetResult.elementAt(i + 12)%></td>
<%if(bolIsBasic){%>
		<td width="10%" class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
<%}else if(strMapRef.equals("1")){%>
		<td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
<%}else{%>
  	    <td class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <%}%>
  	    <td class="thinborder" align="center">
			<input type="submit" name="122" value=" Delete " style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
		  onClick="PageAction('0','<%=vRetResult.elementAt(i)%>')">	  </td>
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
<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="is_oc" value="<%=WI.fillTextValue("is_oc")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
