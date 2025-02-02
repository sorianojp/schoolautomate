<%@ page language="java" import="utility.*,java.util.Vector,hr.HRCareerFeedback"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript">

function viewList(table,indexname,colname,labelname){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewRecord(index)
{
	var loadPg = "./hr_career_seminars_detail.jsp?info_index="+index;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	document.staff_profile.submit();
}

function EditRecord()
{
	document.staff_profile.page_action.value="2";
	document.staff_profile.submit();
}

function DeleteRecord(index)
{
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	document.staff_profile.submit();
}

function CancelEdit()
{
	location = "./hr_career_seminars.jsp";
}

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value = index;
}

</script>
<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-CAREER DEVELOPMENT-Seminar/Trainings","hr_career_seminars.jsp");

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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","CAREER DEVELOPMENT",request.getRemoteAddr(),
														"hr_career_seminars.jsp");
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
HRCareerFeedback cft = new HRCareerFeedback();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strInfoIndex = WI.fillTextValue("info_index");
String strPageAction = WI.fillTextValue("page_action");

if (strPageAction.compareTo("0") == 0){
	vRetResult = cft.operateOnCFTraining(dbOP,request,0);
	if (vRetResult == null){
		strErrMsg = cft.getErrMsg();
	}else{
		strErrMsg = "Training record removed successfully";
	}	
}else if (strPageAction.compareTo("1") == 0){
	vRetResult = cft.operateOnCFTraining(dbOP,request,1);
	if (vRetResult == null){
		strErrMsg = cft.getErrMsg();
	}else{
		strErrMsg = "Training record added successfully";
	}	
}else if (strPageAction.compareTo("2") == 0){
	vRetResult = cft.operateOnCFTraining(dbOP,request,1);
	if (vRetResult == null){
		strErrMsg = cft.getErrMsg();
	}else{
		strErrMsg = "Training record edited successfully";
	}	
}

vRetResult = cft.operateOnCFTraining(dbOP,request,4);


%>
<form action="" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          TRAININGS/SEMINARS ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="105%"><img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
	  <%=WI.getStrValue(strErrMsg,"&nbsp;")%>
        <table width="92%" border="0" align="center" cellpadding="4" cellspacing="0">
          <tr> 
            <td>&nbsp;</td>
            <td colspan="2"><div align="right"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">Note: 
                Items with (<font color="#FF0000">*</font>) are required.</font></div></td>
          </tr>
		  
          <tr> 
            <td width="55">&nbsp;</td>
            <td width="246">Name of Seminar/Training<font color="#FF0000">*</font></td>
            <td width="555"><select name="training" id="select">
                <option value="">Select Training/Seminar</option>
                <%=dbOP.loadCombo("TRAINING_NAME_INDEX","TRAINING_NAME"," FROM HR_PRELOAD_TRAINING_NAME",strTemp,false)%> </select> <a href='javascript:viewList("HR_PRELOAD_TRAINING_NAME","TRAINING_NAME_INDEX","TRAINING_NAME","TRAINING NAME")'><img src="../../../images/update.gif" border="0"></a></td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Venue<font color="#FF0000">*</font></td>
            <td><input name="venue" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="venue" size="48"></td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Conducted by</td>
            <td><input name="conductor" type= "text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="conductor" size="32"> 
            </td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Inclusive Dates</td>
            <td>From<font color="#FF0000">*</font>: 
              <input name="date_from" type="text"  class="textbox" id="date_from"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="10" readonly="true"> 
              <a href="javascript:show_calendar('staff_profile.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;To: 
              <input name="date_to" type="text"  class="textbox" id="date_to"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  size="10" readonly="true"> 
              <a href="javascript:show_calendar('staff_profile.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              &nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Length in Days/Hours<font color="#FF0000">*</font></td>
            <td><input name="day" type="text"  class="textbox" id="day"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" size="2" maxlength="2"  >
              Days 
              <input name="hours" type="text"  class="textbox" id="hours"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" size="2" maxlength="2"  >
              Hours </td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Open To</td>
            <td><select name="emp_type">
                <option value="0">ALL</option>
                <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp2, false)%> </select></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>No of attendant(s) per <%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            <td><input name="attendants" type="text"  class="textbox" id="attendants"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeypress=" if(event.keyCode<46 || event.keyCode > 57) event.returnValue=false;" size="2" maxlength="2" > 
            </td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td>Mandatory Training</td>
            <td><input name="mandatory" type="checkbox" id="mandatory" value="1"> 
            </td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>Only for New Employees</td>
            <td><input name="for_new" type="checkbox" id="for_new" value="1"></td>
          </tr>
          <tr> 
            <td width="55">&nbsp;</td>
            <td colspan="2"><p><br>
                Notes:<br>
                <textarea name="remarks" cols="64"  rows="5" class="textbox" id="remarks"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></textarea>
              </p>
              <p align="right">&nbsp;</p></td>
          </tr>
          <tr> 
            <td colspan="3"><div align="center"> 
                <% if (iAccessLevel > 1){
				if(strPrepareToEdit.length() == 0) {%>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                <font size="1">click to save entries</font> 
                <%}else{%>
                <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
                to save changes</font><a href='javascript:CancelEdit()'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
                to cancel and clear entries</font> 
                <%}}%>
              </div></td>
          </tr>
        </table> 
        <br>
<% if (vRetResult!= null && vRetResult.size() > 0){ %>
        <table width="100%" border="1" align="center" cellpadding="5" cellspacing="0">
          <tr bgcolor="#CCCCCC"> 
            <td colspan="10"><div align="center"><strong><font color="#000000">FUTURE 
                TRAINING RECORDS</font></strong></div></td>
          </tr>
          <tr> 
            <td width="30%" align="center"><font size="1"><strong>TRAINING / SEMINARS</strong></font></td>
            <td width="30%" align="center"><font size="1"><strong>VENUE</strong></font></td>
            <td width="10%" align="center"><font size="1"><strong>OPEN TO</strong></font></td>
            <td width="10%" align="center"><font size="1"><strong>DATE</strong></font></td>
            <td width="6%" align="center"><font size="1"><strong>MANDATORY</strong></font></td>
            <td width="6%" align="center"><font size="1"><strong>FOR NEW EMPLOYEES</strong></font></td>
            <td colspan="3" align="center"><font size="1"><strong>OPERATIONS</strong></font></td>
          </tr>
	<% for (int i = 0; i < vRetResult.size() ; i +=14) {
	if ((String)vRetResult.elementAt(i+11)!=null) strTemp ="<img src=\"../../../images/tick.gif\">" ;
	else
		strTemp = "&nbsp;";
	if ((String)vRetResult.elementAt(i+12)!=null) strTemp2 ="<img src=\"../../../images/tick.gif\">" ;
	else
		strTemp2 = "&nbsp;";
	%>
          <tr> 
            <td><font size="1"><%=(String)vRetResult.elementAt(i+2)%> </font></td>
            <td><font size="1"><%=(String)vRetResult.elementAt(i+3)%>  </font></td>
            <td><font size="1"><%=(String)vRetResult.elementAt(13)%> </font></td>
            <td align="center"><font size="1"><%=(String)vRetResult.elementAt(i+5)+WI.getStrValue((String)vRetResult.elementAt(i+6)," - ","","")%> </font></td>
            <td align="center"><%=strTemp%></td>
            <td align="center"><%=strTemp2%></td>
            <td width="6%" align="center"><a href="javascript:ViewRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/view.gif" border="0"></a></td>
            <td width="7%" align="center"><a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"></a></td>
            <td width="7%" align="center"><a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a></td>
          </tr>
	<%}// end for loop %>
        </table>
<%} // end vRetResult != null %>
        <hr size="1"></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

