<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLeave"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
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
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage(){
	document.form_.submit();
}
function PrepareToEdit(strIndex){
	document.form_.prepareToEdit.value ="1";
	document.form_.info_index.value = strIndex;
	document.form_.submit();
}

function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}
function ShowHistory (){
	document.form_.show_history.value="1";
	document.form_.submit();
}

function EditRecord(){
	document.form_.page_action.value="2";
	document.form_.submit();
}

function DeleteRecord(index){
	document.form_.page_action.value="0";
	document.form_.info_index.value = index;
	document.form_.submit();
}


function CancelRecord(){
	location = "./leave_credit_by_date.jsp?benefit_index="+document.form_.benefit_index.value+
						 "&semester="+document.form_.semester.value;
}

function loadMaxCoverage() {
	var objInput = document.getElementById("leave_info_");
	var strBenefitIndex = document.form_.benefit_index.value;
	var strSemester = document.form_.semester.value;
	
	if(strBenefitIndex.length == 0 || strSemester.length == 0)
		return;

	this.InitXmlHttpObject(objInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=3002&benefit_index="+strBenefitIndex+
							 "&semester="+strSemester;
 	this.processRequest(strURL);
}

function CopyMonth(){
	document.form_.month_to.value = document.form_.month_fr.value;
}

function CopyDay(){
	document.form_.day_to.value = document.form_.day_fr.value;
}
</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));


	if (WI.fillTextValue("show_history").equals("1")) {%>
	
		<jsp:forward page="./sal_ben_incent_mgmt_benefits_divide_hist.jsp" />
	
<% return ;}
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Salary/Benefits/Incentives Mgmt","leave_credit_by_date.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = -1;

if (!strSchCode.startsWith("AUF")){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"leave_credit_by_date.jsp");
}else{
    iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"leave_credit_by_date.jsp");
}

														
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
Vector vRetResult = null;
Vector vEditResult = null;
Vector vLeaveInfo = null;
HRInfoLeave hrL = new HRInfoLeave();
int i = 0;
int iTemp = 0;
String[] astrNature = {"Accumulated","Convertible to Cash","Non accumulated"};

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strUnit = null;
String[] astrMonth = {" Select Month"," January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};

if (WI.fillTextValue("page_action").equals("0")){
	if(hrL.operateOnLeaveByDate(dbOP, request, 0) != null){
		strErrMsg = " Leave Record for the semester removed successfully";
	}else{
		strErrMsg = hrL.getErrMsg();
	}
}else if (WI.fillTextValue("page_action").equals("1")){
	if(hrL.operateOnLeaveByDate(dbOP, request, 1) != null){
		strErrMsg = " Leave Record for the semester added successfully";
	}else{
		strErrMsg = hrL.getErrMsg();
	}
}else if (WI.fillTextValue("page_action").equals("2")){
	if(hrL.operateOnLeaveByDate(dbOP, request, 2) != null){
		strErrMsg = " Leave Record for the semester updated successfully";
		strPrepareToEdit = "0";
	}else{
		strErrMsg = hrL.getErrMsg();
		strPrepareToEdit = "0";
	}
}

strTemp2 = WI.fillTextValue("benefit_index");
if (strPrepareToEdit.equals("1")){
	vEditResult = hrL.operateOnLeaveByDate(dbOP,request, 3);
	if (vEditResult == null || vEditResult.size() == 0){
		strErrMsg = hrL.getErrMsg();
	}else{
		strTemp2 = (String)vEditResult.elementAt(1);
	}
	
}

vLeaveInfo = hrL.getLeaveBenefitInfo(dbOP, request, strTemp2);

vRetResult = hrL.operateOnLeaveByDate(dbOP,request,4);

%>
<body bgcolor="#663300" class="bgDynamic" onLoad="loadMaxCoverage();">
<form action="./leave_credit_by_date.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25" align="center"  bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        LEAVE CREDIT BY DATE PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="39"><strong>&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg, "<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25"> 
        <table width="99%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
          <tr>
            <td width="3%">&nbsp;</td>
            <td width="21%" height="25">Leave Type</td>
            <td width="76%">
						<% 
							if (vEditResult != null){
									strTemp = (String)vEditResult.elementAt(1);
							 }else 
									strTemp = WI.fillTextValue("benefit_index");
						%>
              <select name="benefit_index" onChange="loadMaxCoverage();">
								<option value="">Select Leave</option>
            <%=dbOP.loadCombo("benefit_index","SUB_TYPE", " from HR_BENEFIT_INCENTIVE " +
							" where is_valid = 1 " +
							" and exists(select * from hr_info_leave_per_sem where is_valid = 1 " +
							"    and hr_info_leave_per_sem.benefit_index = HR_BENEFIT_INCENTIVE.benefit_index " +
							"    and semester = "+ WI.getStrValue(WI.fillTextValue("semester"),null) + ")", strTemp, false)%>
            </select></td>
          </tr>
					<tr>
            <td>&nbsp;</td>
            <td height="19" colspan="2">
						<table width="100%" height="17" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">              
              <tr>
                <td nowrap>Max Leave for Term <label id="leave_info_"></label></td>
                </tr>
            </table>
						</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td height="25">Term</td>
            <td><select name="semester" id="semester" onChange="loadMaxCoverage();">
            <% if (vEditResult != null) 
								strTemp =WI.getStrValue((String)vEditResult.elementAt(2));
							else
								strTemp=WI.fillTextValue("semester");
									
							if (strTemp.equals("1")) {
						%>
              <option value="1" selected>1st Semester</option>
              <%}else{%>
              <option value="1">1st Semester</option>
              <%} if (strTemp.equals("2")){%>
              <option value="2" selected>2nd Semester</option>
              <%}else{%>
              <option value="2">2nd Semester</option>
              <%} if (strTemp.equals("3")){%>
              <option value="3" selected>3rd Trimester</option>
              <%}else{%>
              <option value="3">3rd Trimester</option>
              <%} if (strTemp.equals("0")){%>
              <option value="0" selected>Summer</option>
              <%}else{%>
              <option value="0">Summer</option>
              <%}%>
            </select></td>
          </tr>
          
          <tr>
            <td valign="bottom">&nbsp;</td>
            <td height="18" valign="bottom">Duration</td>
						<%
							 if (vEditResult != null) 
								strTemp = (String)vEditResult.elementAt(3);
							else
								strTemp = WI.fillTextValue("duration_days");
						%>
            <td height="18" valign="bottom">
						<input name="duration_days" type="text" class="textbox"   
			onfocus="style.backgroundColor='#D3EBFF'" 
			onblur="style.backgroundColor='white';AllowOnlyFloat('form_','duration_days')" 
			onKeyUp="AllowOnlyFloat('form_','duration_days')" value="<%=WI.getStrValue(strTemp)%>" size="3" maxlength="3" > <%=WI.getStrValue(strUnit)%></td>
          </tr>
          <tr>
            <td valign="bottom">&nbsp;</td>
            <td height="18" valign="bottom" nowrap>Month/Day Range </td>
            <td height="18" valign="bottom"><select name="month_fr" onChange="CopyMonth();">
              <% 
	  	for (i = 1; i <= 12; ++i) {
	  		if (Integer.parseInt(WI.getStrValue(request.getParameter("month_fr"),"0")) == i) {
	  %>
              <option value="<%=i%>" selected><%=astrMonth[i]%></option>
              <%}else{%>
              <option value="<%=i%>"><%=astrMonth[i]%></option>
              <%} 
	  } // end for lop%>
            </select>
              <select name="day_fr" onChange="CopyDay();">
                <%
				strTemp = WI.getStrValue(WI.fillTextValue("day_fr"),"0");
				iTemp = Integer.parseInt(strTemp);
				for(i=1; i<=31; ++i){ 
				  if(iTemp == i){%>
                <option selected value="<%=i%>"><%=i%></option>
                <%}else{%>
                <option value="<%=i%>"><%=i%></option>
                <%}
				}%>
              </select> 
              to 
              <select name="month_to">
                <% 
	  	for (i = 1; i <= 12; ++i) {
	  		if (Integer.parseInt(WI.getStrValue(request.getParameter("month_to"),"0")) == i) {
	  %>
                <option value="<%=i%>" selected><%=astrMonth[i]%></option>
                <%}else{%>
                <option value="<%=i%>"><%=astrMonth[i]%></option>
                <%} 
	  } // end for lop%>
              </select>
              <select name="day_to">
                <%
				strTemp = WI.getStrValue(WI.fillTextValue("day_to"),"0");
				iTemp = Integer.parseInt(strTemp);
				for(i=1; i<=31; ++i){ 
				  if(iTemp == i){%>
                <option selected value="<%=i%>"><%=i%></option>
                <%}else{%>
                <option value="<%=i%>"><%=i%></option>
                <%}
				}%>
              </select></td>
          </tr>          
          <tr>
            <td height="22" colspan="3" valign="bottom">&nbsp; </td>
          </tr>
          <tr> 
            <td height="31" colspan="3" align="center" valign="bottom">
		<%if (iAccessLevel > 1 ) {
			if (vEditResult == null || vEditResult.size() == 0) {
		%>
			<a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"  id="hide_save"></a><font size="1">click 
                to save entries
		  <%}else{%>
				<a href="javascript:EditRecord()"><img src="../../../images/edit.gif" width="40" height="26" border="0" ></a>click to edit record  
		    <%}%>
		    <a href="javascript:CancelRecord()"><img src="../../../images/cancel.gif" border="0" ></a>click 
                to cancel/clear entries </font>
		  <%}%>			</td>
          </tr>
        </table>
		<table width="99%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr>
            <td height="10">&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td width="50%" height="10">&nbsp;</td>
            <td width="50%">&nbsp;</td>
          </tr>
        </table>
				<table width="100%" border="0" align="center"  cellpadding="0" cellspacing="0" class="thinborder">
          <tr bgcolor="#F9F0EC"> 
            <td height="25" colspan="7" align="center" bgcolor="#F9F0EC" class="thinborder"><strong><font size="2">LIST 
                OF LEAVE ASSIGNMENT SETTINGS</font></strong></td>
          </tr>
          <tr> 
            <td width="13%" height="25" align="center" class="thinborder"> <font size="1"><strong> 
            TERM </strong></font></td>
            <td width="19%" height="25" align="center" class="thinborder"><font size="1"><strong>LEAVE</strong></font></td>
            <td width="26%" align="center" class="thinborder"><font size="1"><strong>DURATION</strong></font></td>
            <td width="12%" align="center" class="thinborder"><font size="1"><strong>FROM</strong></font></td>
            <td width="13%" align="center" class="thinborder"><font size="1"><strong>TO</strong></font></td>
            <td colspan="2" align="center" class="thinborder"><font size="1"><strong>OPTIONS</strong></font></td>
          </tr>
          <% if (vRetResult == null || vRetResult.size() == 0){%>
          <tr bgcolor="#F7FBF8"> 
            <td height="25" colspan="7" align="center" bgcolor="#F7FBF8" class="thinborder"><strong><font size="2">********* 
              No Active Record *****</font></strong></td>
          </tr>
          <%}else{ 
	
	String[] astrSemester = {"Summer", "1st Sem","2nd Sem","3rd Sem", "ALL "};
	for (i=0; i < vRetResult.size() ; i+=12) {%>
          <tr> 
            <td class="thinborder">&nbsp;<%=astrSemester[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2),"4"))]%></td>
            <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
						<%
							strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5));
							if(strTemp.equals("5"))
								strTemp = " Hour(s)";
							else
								strTemp = " Day(s)";
						%>
            <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%> <%=strTemp%></td>
						<%
							strTemp = (String)vRetResult.elementAt(i+6);
							strTemp = astrMonth[Integer.parseInt(strTemp)];
							strTemp += " "+(String)vRetResult.elementAt(i+7);
						%>
            <td class="thinborder"><%=strTemp%></td>
						<%
							strTemp = (String)vRetResult.elementAt(i+8);
							strTemp = astrMonth[Integer.parseInt(strTemp)];
							strTemp += " "+(String)vRetResult.elementAt(i+9);
						%>
            <td class="thinborder"><%=strTemp%></td>
            <td width="7%" height="29" align="center" class="thinborder"> <% if (iAccessLevel > 1) {%> <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');"> 
              <img name="image2" src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
              <%}else{%>
              NA 
              <%}%> </td>
            <td width="10%" height="29" align="center" class="thinborder">
						<% if (iAccessLevel ==2) {%> 
							<a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>');"> 
              <img name="image3" src="../../../images/delete.gif" border="0"></a>	
              <%}else{%>
              NA 
              <%}%>						</td>
          </tr>
          <%}
	}%>
        </table>
      </td>
</tr>
</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">Note : Auto credit leaves currently works only for 'Sick leave'.</td>
    </tr>
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value ="<%=strPrepareToEdit%>">
<input type="hidden" name="show_history" value="0">
<input type="hidden" name="is_benefit" value="<%=WI.fillTextValue("is_benefit")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
