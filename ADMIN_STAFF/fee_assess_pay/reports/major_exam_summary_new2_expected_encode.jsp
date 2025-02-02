<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
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
<body bgcolor="#D2AE72">
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
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assess & Payment - Reports - Promisory Note record unclaimed Permit.",
								"major_exam_summary_new2_expected_encode.jsp");
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

String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
String strSYFrom     	= WI.fillTextValue("sy_from");
String strSemester   	= WI.fillTextValue("semester");
String strExamPeriod 	= WI.fillTextValue("pmt_schedule");
String strExpectedAmt   = ConversionTable.replaceString(WI.fillTextValue("expected_amt"),",","");
String strCollegeIndex  = WI.fillTextValue("college_i");	
String strInfoIndex  	= WI.fillTextValue("info_index");

String strPageAction = WI.fillTextValue("page_action");

Vector vRetResult = new Vector();
Vector vEditInfo  = new Vector();
	
if(strSYFrom.length() > 0 && strSemester.length() > 0 && strExamPeriod.length() > 0) {
	
	if(strPageAction.length() > 0 && Integer.parseInt(strPageAction) < 3) {
		
		if(strPageAction.equals("0")) {
			if(strInfoIndex.length() == 0) 
				strErrMsg = "Expected Collection Reference is not found.";
			else {
				strTemp = "update AUF_MAJOR_EXAM_EXPECTED  set is_valid = 0, LAST_MOD_BY = "+(String)request.getSession(false).getAttribute("userIndex")+
				", LAST_MOD_DATE = '"+WI.getTodaysDate()+"' where EXPECTED_INDEX= "+strInfoIndex;
				if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1) 
					strErrMsg = "Error in SQL Query. Failed to remove Information.";				
				else{
					strErrMsg = "Expected Collection Record successfully removed.";
					strPrepareToEdit = "0";	
				}
			}
		}
		else {//add or edit..
		
			if(strExpectedAmt.length() == 0)
				strErrMsg = "Please encode amount of expected collection";
			else{
				
				strTemp = "select EXPECTED_INDEX from AUF_MAJOR_EXAM_EXPECTED where is_valid =1 and EXAM_PERIOD_INDEX = "+strExamPeriod+
					" and sy_from_ ="+strSYFrom+" and sem_="+strSemester+" and COLLEGE_INDEX="+strCollegeIndex;
				if(strPageAction.equals("2") && strInfoIndex.length() > 0)
					strTemp += " and EXPECTED_INDEX <> "+strInfoIndex;
				if(dbOP.getResultOfAQuery(strTemp, 0) != null)
					strErrMsg = "Cannot create duplicate entry.";
				else{
					if(strPageAction.equals("2")) {
						if(strInfoIndex.length() == 0) 
							strErrMsg = "Expected Collection Reference is not found.";
						else {
							strTemp = "Update AUF_MAJOR_EXAM_EXPECTED set EXPECTED_AMT = "+strExpectedAmt +",LAST_MOD_BY = "+(String)request.getSession(false).getAttribute("userIndex")+
								  ", LAST_MOD_DATE = '"+WI.getTodaysDate()+"' where EXPECTED_INDEX = "+strInfoIndex;	
							if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1) 
								strErrMsg = "Error in SQL Query. Failed to record unclaimed permit Information.";				
							else{					
								strPrepareToEdit = "0";	
								strErrMsg = "Expected Collection Information successfully updated.";						
							}
						}
					}else {
						strTemp = " insert into AUF_MAJOR_EXAM_EXPECTED (COLLEGE_INDEX,EXAM_PERIOD_INDEX,SY_FROM_,SEM_,EXPECTED_AMT,CREATED_BY,CREATED_DATE) values ( "+
							strCollegeIndex+","+strExamPeriod+","+strSYFrom+","+strSemester+","+strExpectedAmt+","+(String)request.getSession(false).getAttribute("userIndex")+
							",'"+WI.getTodaysDate()+"')";
						
						if(dbOP.executeUpdateWithTrans(strTemp, null, null, false) == -1) 
							strErrMsg = "Error in SQL Query. Failed to record expected collection Information.";				
						else{	
							strErrMsg = "Expected Collection Information successfully saved.";				
							strPrepareToEdit = "0";	
						}
					}
				}
			}		
		}/////////// end of add or edit.
		
	}///////// end of page_action.
	
	strTemp =
		" select EXPECTED_INDEX, EXPECTED_AMT, exam_name,college.c_code, college.c_name  "+
		" from AUF_MAJOR_EXAM_EXPECTED "+
		" join college on (c_index = COLLEGE_INDEX) "+
		" join FA_PMT_SCHEDULE on (FA_PMT_SCHEDULE.PMT_SCH_INDEX = EXAM_PERIOD_INDEX) "+
		" where AUF_MAJOR_EXAM_EXPECTED.IS_VALID = 1 "+
		" and sy_from_ = "+strSYFrom+
		" and SEM_ ="+strSemester+" order by c_code";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		vRetResult.addElement(rs.getString(1));//[0] expected_index
		vRetResult.addElement(rs.getString(2));//[1] expected amt
		vRetResult.addElement(rs.getString(3));//[2] exam name
		vRetResult.addElement(rs.getString(4));//[3] college code,		
		vRetResult.addElement(rs.getString(5));//[4] college name.
	}rs.close();
	
	/**
	if(strPrepareToEdit.equals("1") && strInfoIndex.length() > 0){
		strTemp =
			" select EXPECTED_INDEX, up_amount, exam_name,EXAM_PERIOD_INDEX  "+
			" from AUF_MAJOR_EXAM_EXPECTED "+
			" join FA_PMT_SCHEDULE on (FA_PMT_SCHEDULE.PMT_SCH_INDEX = EXAM_PERIOD_INDEX) "+
			" where AUF_MAJOR_EXAM_EXPECTED.IS_VALID = 1 "+
			" and stud_index = "+strStudIndex+
			" and sy_from_ = "+strSYFrom+
			" and SEM_ ="+strSemester+
			" and EXPECTED_INDEX = "+strInfoIndex;
		rs = dbOP.executeQuery(strTemp);
		if(rs.next()) {
			vEditInfo.addElement(rs.getString(1));
			vEditInfo.addElement(rs.getString(2));
			vEditInfo.addElement(rs.getString(3));
			vEditInfo.addElement(rs.getString(4));
		}rs.close();
	}**/
}






%>
<form action="./major_exam_summary_new2_expected_encode.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="tHeader1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>:::: RECORD EXPECTED COLLECTION ::::</strong></font></div></td>
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
      <td> <%
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
        </select>	  </td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">Exam Period</td>
      <td width="77%">  
<%
strErrMsg = WI.fillTextValue("pmt_schedule");
if(vEditInfo != null && vEditInfo.size() > 0)
	strErrMsg = (String)vEditInfo.elementAt(3);
%>
<select name="pmt_schedule">
  <%=dbOP.loadCombo("PMT_SCH_INDEX","EXAM_NAME"," from FA_PMT_SCHEDULE where is_del=0 and is_valid=1 order by EXAM_PERIOD_ORDER asc",strErrMsg, false)%>
</select>
<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a></td>
      </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>College</td>
      <td>
<%
strErrMsg = WI.fillTextValue("college_i");
if(vEditInfo != null && vEditInfo.size() > 0)
	strErrMsg = (String)vEditInfo.elementAt(3);
%>
	  <select name="college_i">
      <%=dbOP.loadCombo("c_index","c_code, c_name"," from college where is_del=0 order by c_code",strErrMsg, false)%> </select>      </td>
	  </td>
      </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Expected Collection</td>
	  <%
	  strExpectedAmt = WI.fillTextValue("expected_amt");
	  if(vEditInfo != null && vEditInfo.size() > 0)
	  	strExpectedAmt = CommonUtil.formatFloat((String)vEditInfo.elementAt(1),true);
	  %>
      <td><input name="expected_amt" type="text" size="16" maxlength="16" value="<%=strExpectedAmt%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'"  onBlur="style.backgroundColor='white'"></td>
      </tr>
    <tr>
        <td height="25">&nbsp;</td>
        <td>&nbsp;</td>
        <td>
		<%
		if(strPrepareToEdit.equals("0")){	
		%>
		<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save information</font>
		<%}else{%>
		<a href="javascript:PageAction('2','');"><img src="../../../images/edit.gif" border="0"></a>
		<font size="1">Click to update information</font>
		<%}%>		</td>
        </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){
%> 
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td>&nbsp;</td></tr>
	<tr>
	  <td align="center" height="25"><strong>EXPECTED COLLECTION DETAILS </strong></td>
	</tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr align="center" style="font-weight:bold">
	  <td class="thinborder" width="45%">COLLEGE</td>
		<td class="thinborder" width="15%" height="25">EXAM PERIOD</td>
		<td class="thinborder" width="25%">EXPECTED AMOUNT </td>
		<td class="thinborder" width="15%">OPTION</td>
	</tr>
	<%
	for(int i = 0; i < vRetResult.size(); i+=5){
	%>
	<tr>
	  <td class="thinborder"><%=vRetResult.elementAt(i + 3)%> -- <%=vRetResult.elementAt(i + 4)%></td>
		<td class="thinborder" height="22"><%=WI.getStrValue(vRetResult.elementAt(i+2),"N/A")%></td>
		<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true)%>&nbsp;</td>
		<td align="center" class="thinborder"><a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');"><img src="../../../images/delete.gif" border="0"></a>		</td>
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