<%	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5   = (String)request.getSession(false).getAttribute("info5");
%>
	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>

<script language="JavaScript">
function OpenSearch() {
	var pgLoc = "../../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.form_.stud_id.value = strID;
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}


function ReloadPage(){
	document.form_.submit();
}

function ajaxUpdate(objField, strRef) {
	
	var strNewVal = objField.value;
	if(strNewVal.length == 0 || strRef.length == 0)
		return;
	var strOrigVal = document.form_.orig_val.value;
	
	if(strOrigVal.length > 0 && strOrigVal == strNewVal) 
		return;
	
	var objCOAInput = objField;

	var strParam = "new_val="+escape(strNewVal)+"&cur_hist_index="+strRef;	
	this.InitXmlHttpObject(objCOAInput, 1);//I want to get value in this.retObj
  	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=6200&"+strParam;

	this.processRequest(strURL);
}

function FocusID(){
	document.form_.stud_id.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="FocusID();">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS","school_days_present_mpc.jsp");
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
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"school_days_present_mpc.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
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

enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();


Vector vRetResult = new Vector();
Vector vStudInfo = null;

String strStudID = WI.fillTextValue("stud_id");

if(strStudID.length() > 0){
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, strStudID);
	if(vStudInfo == null)
		strErrMsg = offlineAdm.getErrMsg();
	else{
		strStudID = WI.getInsertValueForDB(strStudID, true, null);
	
		strTemp = 
			" select CUR_HIST_INDEX, course_offered.COURSE_CODE, course_name , "+
			" major.course_code, MAJOR_NAME, SY_FROM, SY_TO, SEMESTER, MPC_SPR_SCHOOL_DAYS "+
			" from stud_curriculum_hist "+
			" join COURSE_OFFERED on (COURSE_OFFERED.COURSE_INDEX = STUD_CURRICULUM_HIST.COURSE_INDEX) "+
			" left join MAJOR on (major.MAJOR_INDEX = STUD_CURRICULUM_HIST.MAJOR_INDEX) "+
			" where USER_INDEX = (select user_index from user_table where id_number = "+strStudID+")"+
			" and stud_curriculum_hist.IS_VALID =1 "+
			" order by SY_FROM asc, SEMESTER asc ";
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		while(rs.next()){
			vRetResult.addElement(rs.getString(1));//[0]CUR_HIST_INDEX
			vRetResult.addElement(rs.getString(2));//[1]COURSE_CODE
			vRetResult.addElement(rs.getString(3));//[2]course_name
			vRetResult.addElement(rs.getString(4));//[3]COURSE_CODE
			vRetResult.addElement(rs.getString(5));//[4]MAJOR_NAME
			vRetResult.addElement(rs.getString(6));//[5]SY_FROM
			vRetResult.addElement(rs.getString(7));//[6]SY_TO
			vRetResult.addElement(rs.getString(8));//[7]SEMESTER
			vRetResult.addElement(rs.getString(9));//[8]MPC_SPR_SCHOOL_DAYS
		}rs.close();
		if(vRetResult.size() == 0)
			strErrMsg = "No student information found.";
	}
	
	


}

%>
<form action="./school_days_present_mpc.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor="#A49A6A">
		<td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: ENCODE SCHOOL DAYS PRESENT ::::</strong></font></div></td>
	</tr>
	<tr bgcolor="#FFFFFF"><td width="3%">&nbsp;</td><td><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="17%">ID Number</td>
		<td width="13%">
			<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
		</td>
		<td width="67%">
			<a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0" align="absmiddle"></a>
			<a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" border="0" align="absmiddle"></a>
			  <label id="coa_info" style="font-size:11px; width:400px; position:absolute;"></label>
		</td>
		
	</tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){

String strCourseName = null;
String strMajorName  = null;
String strPrevName   = "";
int iCount = 0;
String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester"};
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=9){
		strCourseName = WI.getStrValue((String)vRetResult.elementAt(i+2));
		strMajorName  = WI.getStrValue((String)vRetResult.elementAt(i+4));
		
		if(!strPrevName.equals(strCourseName+strMajorName)){
			strPrevName = strCourseName+strMajorName;
	%>
	<tr>
		<td height="20" colspan="2" bgcolor="#CCCCCC"><%=strCourseName+WI.getStrValue(strMajorName,"/","","")%></td>
	</tr>
		<%}%>
	<tr>
		<td width="68%" height="22" style="padding-left:50px;">
			<%=vRetResult.elementAt(i+5)%>-<%=vRetResult.elementAt(i+6)%> <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></td>
		<%
		strTemp = WI.getStrValue(vRetResult.elementAt(i+8));
		%>
		<td width="32%">
			<input name="cur_hist_index_<%=++iCount%>"
				type="text" size="5" value="<%=strTemp%>" class="textbox"
			  	onFocus="document.form_.orig_val.value=document.form_.cur_hist_index_<%=iCount%>.value;style.backgroundColor='#D3EBFF'" 
			  	onBlur="ajaxUpdate(document.form_.cur_hist_index_<%=iCount%>, '<%=vRetResult.elementAt(i)%>','<%=strTemp%>');style.backgroundColor='white'">
			<label id="coa_info_<%=iCount%>" style="font-size:11px; width:400px; position:absolute;"></label>
		</td>
	</tr>	
		
	<%}%>
</table>

<%}%>



<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="orig_val">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
