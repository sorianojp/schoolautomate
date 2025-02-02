<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function PrintPg() {
	var loadPg = "./promisory_record_unclaimed_permit_print.jsp?c_index="+document.form_.c_index.value+
	"&sy_from="+document.form_.sy_from.value+
	"&semester="+document.form_.semester.value+
	"&pmt_schedule="+document.form_.pmt_schedule.value+
	"&rows_per_pg="+document.form_.rows_per_pg.value;
	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AjaxMapName() {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 2)
			return;		
		var objCOAInput = document.getElementById("coa_info");			
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

function RefreshPage(){
	document.form_.submit();
}

function PageAction(strAction,strInfoIndex){
	if(strAction == "0"){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}

	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	document.form_.page_action.value = strAction;
	document.form_.prepareToEdit.value = "";
	if(strAction == "3")
		document.form_.prepareToEdit.value = "1";
	
	document.form_.submit();
}

</script>
<body bgcolor="#D2AE72" onLoad="document.form_.stud_id.focus()">
<%@ page language="java" import="utility.*,java.util.Vector, java.util.Date" buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FEE ASSESSMENT & PAYMENTS"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assess & Payment - Reports - Promisory Note record unclaimed Permit.",
								"promisory_record_unclaimed_permit_encode.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
String strSYFrom     	= WI.fillTextValue("sy_from");
String strSemester   	= WI.fillTextValue("semester");
String strExamPeriod 	= WI.fillTextValue("pmt_schedule");
String strUPAmount   = ConversionTable.replaceString(WI.fillTextValue("uc_permit"),",","");
String strStudID     	= WI.fillTextValue("stud_id");	
String strInfoIndex  	= WI.fillTextValue("info_index");	
String strStudIndex  	= null;
String strPageAction = WI.fillTextValue("page_action");

Vector vStudInfo = null;
Vector vRetResult = new Vector();
Vector vEditInfo  = new Vector();
enrollment.OfflineAdmission offlineAdm = new enrollment.OfflineAdmission();
	
if(strStudID.length() > 0) {	
	vStudInfo = offlineAdm.getStudentBasicInfo(dbOP, strStudID);
	if(vStudInfo == null || vStudInfo.size() ==0)
		strErrMsg = offlineAdm.getErrMsg();
	else 
		strStudIndex = (String)vStudInfo.elementAt(12);				
}
	
if(strSYFrom.length() > 0 && strSemester.length() > 0 && strExamPeriod.length() > 0 && strStudIndex != null) {
	
	if(strPageAction.length() > 0 && Integer.parseInt(strPageAction) < 3) {
		
		if(strPageAction.equals("0")) {
			if(strInfoIndex.length() == 0) 
				strErrMsg = "Unclaimed Permit Information not found.";
			else {
				strTemp = "update AUF_UNCLAIMED_PERMIT set is_valid = 0, LAST_MOD_BY = "+(String)request.getSession(false).getAttribute("userIndex")+
				", LAST_MOD_DATE = '"+WI.getTodaysDate()+"' where up_index= "+strInfoIndex;
				if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1) 
					strErrMsg = "Error in SQL Query. Failed to remove Information.";				
				else{
					strErrMsg = "Unclaimed Permit Information successfully removed.";
					strPrepareToEdit = "0";	
				}
			}
		}
		else {//add or edit..
		
			if(strUPAmount.length() == 0)
				strErrMsg = "Please encode amount of unclaimed permit.";
			else{
				
				strTemp = "select up_index from AUF_UNCLAIMED_PERMIT where is_valid =1 and EXAM_PERIOD_INDEX = "+strExamPeriod+
					" and sy_from_ ="+strSYFrom+" and sem_="+strSemester+" and stud_index="+strStudIndex;
				if(strPageAction.equals("2") && strInfoIndex.length() > 0)
					strTemp += " and up_index <> "+strInfoIndex;
				if(dbOP.getResultOfAQuery(strTemp, 0) != null)
					strErrMsg = "Cannot create duplicate entry.";
				else{
					if(strPageAction.equals("2")) {
						if(strInfoIndex.length() == 0) 
							strErrMsg = "Unclaimed Permit Information not found.";
						else {
							strTemp = "Update AUF_UNCLAIMED_PERMIT set UP_AMOUNT = "+strUPAmount +",LAST_MOD_BY = "+(String)request.getSession(false).getAttribute("userIndex")+
								  ", LAST_MOD_DATE = '"+WI.getTodaysDate()+"' where up_index = "+strInfoIndex;	
							if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1) 
								strErrMsg = "Error in SQL Query. Failed to record unclaimed permit Information.";				
							else{					
								strPrepareToEdit = "0";	
								strErrMsg = "Unclaimed Permit Information successfully updated.";						
							}
						}
					}else {
						strTemp = " insert into AUF_UNCLAIMED_PERMIT (STUD_INDEX,EXAM_PERIOD_INDEX,SY_FROM_,SEM_,UP_AMOUNT,CREATED_BY,CREATED_DATE) values ( "+
							strStudIndex+","+strExamPeriod+","+strSYFrom+","+strSemester+","+strUPAmount+","+(String)request.getSession(false).getAttribute("userIndex")+
							",'"+WI.getTodaysDate()+"')";
						
						if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1) 
							strErrMsg = "Error in SQL Query. Failed to record unclaimed permit Information.";				
						else{	
							strErrMsg = "Unclaimed Permit Information successfully saved.";				
							strPrepareToEdit = "0";	
						}
					}
				}
			}		
		}/////////// end of add or edit.
		
	}///////// end of page_action.
	
	strTemp =
		" select up_index, up_amount, exam_name  "+
		" from AUF_UNCLAIMED_PERMIT "+
		" join FA_PMT_SCHEDULE on (FA_PMT_SCHEDULE.PMT_SCH_INDEX = EXAM_PERIOD_INDEX) "+
		" where AUF_UNCLAIMED_PERMIT.IS_VALID = 1 "+
		" and stud_index = "+strStudIndex+
		" and sy_from_ = "+strSYFrom+
		" and SEM_ ="+strSemester;
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		vRetResult.addElement(rs.getString(1));
		vRetResult.addElement(rs.getString(2));
		vRetResult.addElement(rs.getString(3));
	}rs.close();
	
	if(strPrepareToEdit.equals("1") && strInfoIndex.length() > 0){
		strTemp =
			" select up_index, up_amount, exam_name,EXAM_PERIOD_INDEX  "+
			" from AUF_UNCLAIMED_PERMIT "+
			" join FA_PMT_SCHEDULE on (FA_PMT_SCHEDULE.PMT_SCH_INDEX = EXAM_PERIOD_INDEX) "+
			" where AUF_UNCLAIMED_PERMIT.IS_VALID = 1 "+
			" and stud_index = "+strStudIndex+
			" and sy_from_ = "+strSYFrom+
			" and SEM_ ="+strSemester+
			" and up_index = "+strInfoIndex;
		rs = dbOP.executeQuery(strTemp);
		if(rs.next()) {
			vEditInfo.addElement(rs.getString(1));
			vEditInfo.addElement(rs.getString(2));
			vEditInfo.addElement(rs.getString(3));
			vEditInfo.addElement(rs.getString(4));
		}rs.close();
	}
}






%>
<form action="./promisory_record_unclaimed_permit_encode.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="tHeader1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: RECORD UNCLAIMED PERMIT ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="tHeader2">
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="is_basic" value="1"<%=strTemp%> onClick="relaunchPage();"> Process Promisory Note for Grade School	  </td>
    </tr>
-->
    <tr> 
      <td height="25">&nbsp;</td>
      <td>SY/TERM</td>
      <td colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> 

<%if(bolIsBasic){%>
<input type="hidden" name="semester" value="1">
<%}else{%>
	  <select name="semester">
          <%strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}%>
        </select>
<%}%>	  </td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Exam Period</td>
      <td width="15%">  
<%
if(bolIsBasic)
	strTemp = "2";
else	
	strTemp = "1";
	
strErrMsg = WI.fillTextValue("pmt_schedule");
if(vEditInfo != null && vEditInfo.size() > 0)
	strErrMsg = (String)vEditInfo.elementAt(3);
%>
	  <select name="pmt_schedule">
      <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid="+strTemp+" order by EXAM_PERIOD_ORDER asc",strErrMsg, false)%> </select>      </td>
      <td width="67%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Student ID </td>
      <td>
	  <input name="stud_id" type="text" size="16" maxlength="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(event);">	  </td>
      <td><label id="coa_info" style="font-size:11px; width:400px; font-weight:bold; color:#0000FF; position:absolute"></label></td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td>&nbsp;</td>
        <td colspan="2"><a href="javascript:RefreshPage();"><img src="../../../../images/refresh.gif" border="0"></a></td>
        </tr>
    <!--<tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2" style="font-size:9px;">Note: After entering ID Press ENTER to reload the page/fill up Unclaimed Permit if already encoded. </td>
      </tr>-->
<%
if(vStudInfo != null && vStudInfo.size() > 0){
%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Unclaimed Permit </td>
	  <%
	  strUPAmount = WI.fillTextValue("uc_permit");
	  if(vEditInfo != null && vEditInfo.size() > 0)
	  	strUPAmount = CommonUtil.formatFloat((String)vEditInfo.elementAt(1),true);
	  %>
      <td><input name="uc_permit" type="text" size="16" maxlength="16" value="<%=strUPAmount%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" 
	   onKeyUp="AllowOnlyFloat('form_','uc_permit');"
	  onBlur="AllowOnlyFloat('form_','uc_permit');style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
    </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td>&nbsp;</td>
        <td colspan="2">
		<%
		if(strPrepareToEdit.equals("0")){	
		%>
		<a href="javascript:PageAction('1','');"><img src="../../../../images/save.gif" border="0"></a>
		<font size="1">Click to save information</font>
		<%}else{%>
		<a href="javascript:PageAction('2','');"><img src="../../../../images/edit.gif" border="0"></a>
		<font size="1">Click to update information</font>
		<%}%>
		</td>
        </tr>
    <!--<tr> 
      <td height="35">&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2" valign="bottom">
<%if(strInfoIndex != null) {%>
		<input name="submit22" type="submit" style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
			value="Update Unclaimed Permit" onClick="document.form_.page_action.value='1'">	  &nbsp;&nbsp;&nbsp;
			
		<input name="submit22" type="submit" style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
			value="Remove Unclaimed Permit" onClick="document.form_.page_action.value='0'">	  &nbsp;&nbsp;&nbsp;
<%}else{%>
		<input name="submit22" type="submit" style="font-size:11px; height:25px;border: 1px solid #FF0000;" 
			value="Save Unclaimed Permit" onClick="document.form_.page_action.value='1'">	  
<%}%>			</td>
    </tr>-->
<%}%>
    <tr valign="bottom">
      <td height="45">&nbsp;</td>
      <td >Print Option <br><font size="1">(Per College)</font></td>
      <td colspan="2" valign="bottom">
	  	Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 45;
if(WI.fillTextValue("rows_per_pg").length() > 0)
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i = 1; i < 70; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	&nbsp; &nbsp;
	  
	  	<select name="c_index" style="width:400px;">
      	<option value="">ALL</option>
		<%=dbOP.loadCombo("c_index","c_name"," from college where is_del = 0 order by c_name asc",request.getParameter("c_index"), false)%> </select>
	  	</td>
    </tr>
    <tr valign="bottom">
      <td height="25">&nbsp;</td>
      <td >&nbsp;</td>
      <td colspan="2" style="font-size:9px;">
	 	 <a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a> Print Report	  </td>
    </tr>

  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
%> 
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td>&nbsp;</td></tr>
	<tr><td align="center" height="25"><strong>LIST OF UNCLAIMED PERMIT</strong></td></tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td class="thinborder" width="38%" height="25" align="center"><strong>EXAM PERIOD</strong></td>
		<td class="thinborder" width="38%" align="center"><strong>AMOUNT</strong></td>
		<td class="thinborder" width="24%" align="center"><strong>OPTION</strong></td>
	</tr>
	<%
	for(int i = 0; i < vRetResult.size(); i+=3){
	%>
	<tr>
		<td class="thinborder" height="22"><%=WI.getStrValue(vRetResult.elementAt(i+2),"N/A")%></td>
		<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true)%>&nbsp;</td>
		<td align="center" class="thinborder">
			<a href="javascript:PageAction('3','<%=vRetResult.elementAt(i)%>');"><img src="../../../../images/edit.gif" border="0"></a>&nbsp;
			<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');"><img src="../../../../images/delete.gif" border="0"></a>
		</td>
	</tr>
	<%}%>
</table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="tFooter">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>