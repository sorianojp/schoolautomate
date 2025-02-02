
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg(strInfoIndex) {
	var pgLoc = "./print_leave_absence.jsp?info_index="+strInfoIndex+"&sy_from="+
		document.form_.sy_from.value+"&sy_to="+document.form_.sy_to.value+"&semester="+document.form_.semester[document.form_.semester.selectedIndex].value;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PageAction(strAction){
	document.form_.page_action.value = strAction;
	document.form_.submit();
}

function AjaxMapName() {
	var strCompleteName = document.form_.stud_id.value;

	if(strCompleteName.length < 2)
		return;
		
	var objCOAInput = document.getElementById("coa_info");

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.stud_id.value = strID;
	document.form_.stud_id.focus();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
	document.form_.submit();
}

function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){				
	var loadPg = "../../../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>

<%@ page language="java" import="utility.*,osaGuidance.GDTrackerServices,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");	
	if (strSchCode == null)
		strSchCode = "";

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-Guidance-Reports-Other","leave_absence.jsp");
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

enrollment.CourseRequirement cRequirement = new enrollment.CourseRequirement();
enrollment.OfflineAdmission OA = new enrollment.OfflineAdmission();
GDTrackerServices trackService = new GDTrackerServices();

java.sql.ResultSet rs = null;

Vector vStudInfo 	= null;

Vector vCRStudInfo 	= null;
Vector vRetResult 	= null;
Vector vStudDevList = null;
Vector vDevList 	= new Vector();


String strSYFrom = null; 
String strSYTo = null; 
String strSemester  = null;
String strTrackerIndex = WI.fillTextValue("info_index");
String strStudID = WI.fillTextValue("stud_id");
String strIsTempStud = "0";
String strIsBasic = "0";
String strUserIndex  = null;

if (strStudID.length() > 0){
	vStudInfo = OA.getStudentBasicInfo(dbOP,strStudID);
	if (vStudInfo == null) 
		strErrMsg= OA.getErrMsg();
	strTemp = dbOP.mapUIDToUIndex(strStudID,4);
	if (strTemp != null)
		strIsTempStud = "0";
	else
		strIsTempStud = "1";
}

if(vStudInfo != null && vStudInfo.size() > 0) {
		strUserIndex = (String)vStudInfo.elementAt(12);
		strSYFrom = (String)vStudInfo.elementAt(10);
		strSYTo = (String)vStudInfo.elementAt(11);
		strSemester = (String)vStudInfo.elementAt(9);
		
		strTemp = "select course_index from stud_curriculum_hist where is_valid =1 and sy_from = "+strSYFrom+
			" and semester = "+strSemester+" and user_index = "+strUserIndex;
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp == null || strTemp.equals("0"))
			strIsBasic = "1";
	

		
	strTemp = "select tracker_extn_index, FIELD_NAME from GD_TRACKER_EXTN";
	rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vDevList.addElement(rs.getString(1));
		vDevList.addElement(rs.getString(2));
	}rs.close();
	
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(trackService.operateOnStudTracker(dbOP, request, Integer.parseInt(strTemp), strUserIndex,strSYFrom,strSemester) == null)
			strErrMsg = trackService.getErrMsg();
		else{
			if(strTemp.equals("1"))
				strErrMsg = "Student profile information successfully saved.";
			if(strTemp.equals("2"))
				strErrMsg = "Student profile information successfully updated.";
		}
	}
	
	
	vRetResult = trackService.operateOnStudTracker(dbOP, request, 4, strUserIndex,strSYFrom,strSemester);

	if(vRetResult == null)
		strErrMsg = trackService.getErrMsg();
	else{
		if(strTrackerIndex.length() == 0)
			strTrackerIndex = WI.getStrValue(trackService.getTrackingIndex());
		vStudDevList = (Vector)vRetResult.remove(0);
	}
	
}

if(vStudDevList == null)
	vStudDevList = new Vector();

String[] astrConvertToSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
if(strIsBasic.equals("1")){
	astrConvertToSem[0] = "Summer";
	astrConvertToSem[1] = "Regular";
}
String[] astrConvertToYr  = {"N/A","1ST YR","2ND YR","3RD YR","4TH YR","5TH YR","6TH YR","7TH YR"};
%>

<body>
<form action="guidance_tracker.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          GUIDANCE TRACKER PAGE ::::</strong></font></div></td>
    </tr>
	<tr><td width="88%" height="25" style="padding-left:30px;"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
	    <td width="12%" align="right">
		<a href="main.jsp"><img src="../../../../../images/go_back.gif" border="0"></a>		</td>
	</tr>
  </table>
  
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="2%" height="25"></td>
      <td width="16%">Student ID: </td>
      <td width="20%">
	<% if (WI.fillTextValue("parent_wnd").length() > 0) strTemp = "readonly = yes";
	   else strTemp = " onKeyUp='AjaxMapName();'";%>
	  
	  <input type="text" name="stud_id" size="20" maxlength="32" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp='AjaxMapName();'></td>
      <td width="10%"><a href="javascript:OpenSearch();"><img src="../../../../../images/search.gif" border="0" align="absmiddle"></a></td>
      <td width="16%"><input name="image" type="image" src="../../../../../images/form_proceed.gif" align="absmiddle"></td>
      <td width="36%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:350px;"></label></td>
    </tr>
    <tr> 
      <td colspan="6"><hr size="1" noshade> </td>
    </tr>
</table>  


<% 
int iFieldCount = 0;
if(vStudInfo != null && vStudInfo.size() > 0){%>
<input type="hidden" name="stud_index" value="<%=strUserIndex%>">
<input type="hidden" name="is_temp_stud" value="<%=strIsTempStud%>">
<input type="hidden" name="sy_from" value="<%=strSYFrom%>">
<input type="hidden" name="sy_to" value="<%=strSYTo%>">
<input type="hidden" name="semester" value="<%=strSemester%>">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td width="2%" height="25">&nbsp;</td>
			<td width="18%">Student Name</td>
			<%
			strTemp = WebInterface.formatName((String)vStudInfo.elementAt(0),(String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4);
			%>
			<td width="33%"><strong><%=strTemp%></strong></td>
			<td width="47%">&nbsp;</td>
		</tr>
	<%
	if(!strIsBasic.equals("1")){
	%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Course/Major(cy)</td>
			<td colspan="2"><strong><%=(String)vStudInfo.elementAt(7)%>
			<%if(vStudInfo.elementAt(8) != null){%>
			/<%=(String)vStudInfo.elementAt(8)%>
			<%}%>
			(<%=(String)vStudInfo.elementAt(3)%> to <%=(String)vStudInfo.elementAt(4)%>
			)</strong></td>
		</tr>
	<%}%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>YEAR LEVEL</td>
			<%
			if(!strIsBasic.equals("1"))
				strTemp = astrConvertToYr[Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(14),"0"))];
			else
				strTemp = dbOP.getBasicEducationLevelNew(Integer.parseInt(WI.getStrValue(vStudInfo.elementAt(14),"0")));
			%>
			<td><strong><%=strTemp%></strong></td>
			<td>SY (TERM ) &nbsp;&nbsp;: &nbsp;&nbsp;<%=strSYFrom + "-" +strSYTo%> 
			<%
			if(Integer.parseInt(strSemester) > 1 && strIsBasic.equals("1"))
				strSemester = "1";
			%>
			(<%=astrConvertToSem[Integer.parseInt(strSemester)]%>)</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Status</td>
			<%
			strTemp = WI.getStrValue(vStudInfo.elementAt(20));
			if(strTemp.length()  > 0){
				strTemp = "select status from user_status where STATUS_INDEX = "+strTemp;
				strTemp = dbOP.getResultOfAQuery(strTemp,0);
			}else
				strTemp = "";
			%>
			<td colspan="2"><strong><%=WI.getStrValue(strTemp)%></strong></td>
		</tr>
		
		<tr>
			<td height="25" colspan="4"><hr size="1"></td>
		</tr>
	</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td width="3%">&nbsp;</td>
		<td>1. How many hours a day do you set aside for studying?</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<%
		
		strTemp = WI.fillTextValue("field_"+(++iFieldCount));			
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(iFieldCount - 1);
				
		%>
		<td><textarea cols="60" rows="2" name="field_<%=iFieldCount%>"><%=strTemp%></textarea></td>
	</tr>
	
	<tr>
		<td width="3%">&nbsp;</td>
		<td valign="bottom" height="30">2. Specify Academics difficulties in the past and how you solved them?</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("field_"+(++iFieldCount));			
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(iFieldCount - 1);
		%>
		<td><textarea cols="60" rows="2" name="field_<%=iFieldCount%>"><%=strTemp%></textarea></td>
	</tr>
	
	<tr>
		<td width="3%">&nbsp;</td>
		<td valign="bottom" height="30">3. Why are you choosing this course?</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("field_"+(++iFieldCount));			
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(iFieldCount- 1);
		%>
		<td><textarea cols="60" rows="2" name="field_<%=iFieldCount%>"><%=strTemp%></textarea></td>
	</tr>
	
	<tr>
		<td width="3%">&nbsp;</td>
		<td valign="bottom" height="30">4. Reason for Choosing UB?</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("field_"+(++iFieldCount));			
		if(vRetResult != null && vRetResult.size() > 0)
			strTemp = (String)vRetResult.elementAt(iFieldCount-1);
		%>
		<td><textarea cols="60" rows="2" name="field_<%=iFieldCount%>"><%=strTemp%></textarea></td>
	</tr>
	
	<tr>
		<td width="3%">&nbsp;</td>
		<td valign="bottom" height="30">5. Check what you need to developed or need help in: 
			<a href='javascript:viewList("GD_TRACKER_EXTN","TRACKER_EXTN_INDEX",
				"FIELD_NAME","CATEGORY", "GD_TRACKER_STUD_DEVELOPMENT", "TRACKER_EXTN_INDEX",
				" and is_valid = 1","","");'><img src="../../../../../images/update.gif" border="0"></a>
			<font size="1">Click to add list below</font>
			
			
			
		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>		
		<td>
		<%
		int iCount = 0;
		strErrMsg = "";
		if(vDevList != null && vDevList.size() > 0){
			for(int i = 0; i < vDevList.size(); i+=2){
			
			if(vStudDevList.indexOf((String)vDevList.elementAt(i)) > -1)
				strErrMsg = "checked";
			else
				strErrMsg = "";
			
			
		%>
			<input type="checkbox" name="dev_<%=++iCount%>" value="<%=vDevList.elementAt(i)%>" <%=strErrMsg%>><%=vDevList.elementAt(i+1)%><br>
		<%}
		}%>
		<input type="hidden" name="dev_total_count" value="<%=iCount%>">
		</td> 
	</tr>
<!--	<tr>
		<td>&nbsp;</td>
		<%
		strTemp = WI.fillTextValue("other_reason");
		%>
		<td>Other : <input type="text" name="other_reason" size="60" maxlength="256" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	</tr>-->
</table>
  

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td align="center">
		<%if(strTrackerIndex.length() == 0){%>
		<a href="javascript:PageAction('1');"><img src="../../../../../images/save.gif" border="0"></a>
		<font size="1">Click to save information</font>
		<%}else{%>
		<a href="javascript:PageAction('2');"><img src="../../../../../images/edit.gif" border="0"></a>
		<font size="1">Click to update information</font>
		<%}%>
		
	</td></tr>
</table>

<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr><td>&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>
<input type="hidden" name="page_action">
<input type="hidden" name="print_pg">
<%
if(iFieldCount == 0)
	iFieldCount = 4;
%>
<input type="hidden" name="field_count" value="<%=iFieldCount%>">
<input type="hidden" name="info_index" value="<%=strTrackerIndex%>">
<%
if(strTrackerIndex.length() == 0)
	strTrackerIndex = "0";
else
	strTrackerIndex = "1";
%>
<input type="hidden" name="update_method" value="<%=strTrackerIndex%>">
<input type="hidden" name="is_basic" value="<%=strIsBasic%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>