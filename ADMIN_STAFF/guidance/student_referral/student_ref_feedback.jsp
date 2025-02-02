<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strAction == "0") {
		if(!confirm("Do you want to delete referral information?"))
			return;
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
	if(strAction == '0')
		document.form_.submit();
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
var AjaxCalledPos;
function AjaxMapName(strPos) {
		AjaxCalledPos = strPos;
		if(strPos == "1") {
			document.getElementById("stud_info1").innerHTML = "...";
			document.getElementById("stud_info2").innerHTML = "...";
		}
		
		var strCompleteName;
		if(strPos == "1")
			strCompleteName = document.form_.stud_id.value;
		else	
			strCompleteName = document.form_.emp_id.value;
			
		if(strCompleteName.length == 0)
			return;
		
		var objCOAInput;
		if(strPos == "1")
			objCOAInput = document.getElementById("coa_info");
		else	
			objCOAInput = document.getElementById("coa_info2");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);
		if(strPos == "2")
			strURL += "&is_faculty=1";
		//if(document.form_.account_type[1].checked) //faculty
		//	strURL += "&is_faculty=1";
		//alert(strURL);
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	if(AjaxCalledPos == "2"){
		document.form_.emp_id.value = strID;
		return;
	}
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
	
	document.getElementById("stud_info1").innerHTML = " == Press press enter to load information. == ";
	document.getElementById("stud_info2").innerHTML = " == Press press enter to load information. == ";
	//alert(strUserIndex);
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	if(AjaxCalledPos == "1")
		document.getElementById("coa_info").innerHTML = strName;
	else	
		document.getElementById("coa_info2").innerHTML = strName;
}

</script>
<body bgcolor="#663300">
<%@ page language="java" import="utility.*,osaGuidance.GDStudReferralFollowUp,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","student_ref_feedback.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance & Counseling","student referral",request.getRemoteAddr(),
														"student_ref_feedback.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
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


GDStudReferralFollowUp cmsNew = new GDStudReferralFollowUp();
Vector vRetResult = null;
Vector vEditInfo  = null;
boolean bolShowOrig = true;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cmsNew.operateOnReferralMain(dbOP, request, Integer.parseInt(strTemp)) == null) {
		strErrMsg   = cmsNew.getErrMsg();
		bolShowOrig = false;
	}
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
String strStudID     = WI.fillTextValue("stud_id");
Vector vStudInfo     = null;
if(strStudID.length() > 0) {
	vRetResult = cmsNew.operateOnReferralMain(dbOP, request, 4);
	if(vRetResult == null) {
		if(strErrMsg == null)
			strErrMsg = cmsNew.getErrMsg();
	}
	else 
		vStudInfo = (Vector)vRetResult.remove(0);
}
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = cmsNew.operateOnReferralMain(dbOP, request, 3);
//System.out.println(vEditInfo);
//System.out.println(cmsNew.getErrMsg());

String strFacultyName = "";



%>
<form action="./student_ref_feedback.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr>
     <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          STUDENT REFERRAL ACTION PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="5%" height="25">&nbsp;</td>
      <td width="22%">Student ID</td>
      <td width="73%">
	  	<input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AjaxMapName('1');"><input type="image" src="../../../images/blank.gif" border="0">
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top"> Student Name</td>
      <td height="25"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"><%if(vStudInfo != null){%><%=vStudInfo.elementAt(0)%><%}%></label></td>
    </tr>
    <tr> 
      <td  width="5%"height="25">&nbsp;</td>
      <td width="22%" height="25">Course</td>
      <td height="25"><strong><label id="stud_info1"><%if(vStudInfo != null){%><%=vStudInfo.elementAt(1)%><%}%></label></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">SY/Term/Year </td>
      <td width="73%" height="25"><strong><label id="stud_info2"><%if(vStudInfo != null){%><%=vStudInfo.elementAt(2)%><%}%></label></strong></td>
    </tr>
<%if(vEditInfo != null && vEditInfo.size() > 0) {//always edit.. %>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><u><strong>Referred by:</strong></u> </td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Employee ID/Name</td>
      <td height="25"><%=vEditInfo.elementAt(11)%> / <%=vEditInfo.elementAt(12)%></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Referral Date </td>
      <td height="25"><%=vEditInfo.elementAt(3)%></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><u>Subject Referred: <%=WI.getStrValue((String)vEditInfo.elementAt(18), "Not Set")%></u></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td colspan="2">Reason(s) for Referral:</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" style="font-size:9px; color:#0000FF"><%=vEditInfo.elementAt(6)%></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="15" colspan="2" valign="bottom" style="font-size:9px;">Urgency Level :<font style="color:#0000FF"> <%=vEditInfo.elementAt(14)%></font></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Action : 
        <select name="action_i">
<%
if(bolShowOrig)
	strTemp = WI.fillTextValue("action_i");
else
	strTemp = (String)vEditInfo.elementAt(8);
%>
          <%=dbOP.loadCombo("action_index","action_name"," from GD_REFERRAL_ACTION order by ACTION_NAME asc", strTemp, false)%>
        </select>
        <a href='javascript:viewList("GD_REFERRAL_ACTION","ACTION_INDEX","ACTION_NAME","ACTION NAME",
	"GD_REFERRAL","ACTION_I", " and GD_REFERRAL.IS_VALID=1","","action_i")'><img src="../../../images/update.gif" border="0"></a><a href="javascript:UpdateUrgency();"></a><font size="1">click 
      to UPDATE Action </font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">Remarks</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">
<%
if(bolShowOrig){
	strTemp = WI.fillTextValue("action_note");
	if(strTemp.length() == 0 && vEditInfo != null && vEditInfo.size() > 0) 
		strTemp = (String)vEditInfo.elementAt(9);
}
else
	strTemp = (String)vEditInfo.elementAt(9);
%>
<textarea name="action_note" cols="90" rows="4" style="font-size:10px" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='#FFFFFF'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" align="center"><%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
        <input type="button" name="Submit" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('10','');document.form_.Submit.disabled=true;document.form_.submit();">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}else{%>
<input type="button" name="EditInfo" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('12','');document.form_.EditInfo.disabled=true;document.form_.submit();">
&nbsp;&nbsp;&nbsp;&nbsp;
<%}
}%>
<input type="button" name="Cancel" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.action_note.value='';document.form_.Cancel.disabled=true;document.form_.submit();"></td>
    </tr>
<%}//end of vEditInfo.. %>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0" class="thinborder">
    <tr bgcolor="#FFCC99"> 
      <td height="25" colspan="7" class="thinborder">
	  <div align="center"><strong><font color="#0000FF">:: LIST OF REFERRALS :: </font></strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="25" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">SY/Term</td>
      <td width="20%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Referred By </td>
      <td width="20%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Date Referred </td>
      <td width="20%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Urgency</td>
      <td width="20%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">Action </td>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">&nbsp;</td>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold;" align="center">&nbsp;</td>
    </tr>
<%
String strLoginID = (String)request.getSession(false).getAttribute("userIndex");
String strActionTakenBy = null;
if(strLoginID == null)
	strLoginID = "";
	
for(int i = 0; i < vRetResult.size(); i += 19){
strActionTakenBy = (String)vRetResult.elementAt(i + 16);
if(strActionTakenBy == null || vRetResult.elementAt(i + 8) == null)
	strActionTakenBy = strLoginID;
%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%> : <%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 11)%><br><%=vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 14)%></td>
      <td class="thinborder" style="font-size:9px"><%=WI.getStrValue(vRetResult.elementAt(i + 15), "&nbsp;")%></td>
      <td class="thinborder">
        <%if(iAccessLevel > 1 && strLoginID.equals(strActionTakenBy) ){%>
        <input type="button" name="122" value=" Edit " style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');document.form_.submit();">
        <%}else{%>&nbsp;<%}%>      </td>
      <td class="thinborder">
        <%if(iAccessLevel ==2  && strLoginID.equals(strActionTakenBy) ){%>
        <input type="button" name="123" value="Delete" style="font-size:11px; height:20px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');">
        <%}else{%>&nbsp;<%}%>      </td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">

<input type="hidden" name="sub_index" value="<%=WI.fillTextValue("sub_index")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>