<%@ page language="java" import="utility.*, health.MedicationMgmt, java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
<!--
function CheckValidHour() {
	var vTime =document.form_.take_time_hr.value 
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.take_time_hr.value = "12";
	}
}
function CheckValidMin() {
	if(eval(document.form_.take_time_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.take_time_min.value = "00";
	}
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vMedications =  null;
	int iTotalDose = 0;
	if (request.getParameter("total_dose").compareTo("null")==0)
			iTotalDose = 0;
		else
			iTotalDose = Integer.parseInt(request.getParameter("total_dose"));
	int iTakenDose = 0;
	String strTRCol = "";
	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String [] astrLoc = {"Home", "Clinic"};	
	String [] astrAMPM = {"AM", "PM"};	
	boolean bolNoRecord = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Medications Management","med_log_detail.jsp");
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
														"Health Monitoring","Medications Management",request.getRemoteAddr(),
														"med_log_detail.jsp.jsp");
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
MedicationMgmt medMgmt= new MedicationMgmt();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
		if(medMgmt.operateOnMedicationLog(dbOP, request, Integer.parseInt(strTemp)) != null ) {
				strErrMsg = "Operation successful.";
				}
		else
				strErrMsg = medMgmt.getErrMsg();
	}
	
vMedications = medMgmt.operateOnMedicationLog(dbOP, request, 5);
	if (strErrMsg==null)
		strErrMsg = medMgmt.getErrMsg();
	if (vMedications!=null)
		iTakenDose = Integer.parseInt((String)vMedications.elementAt(0));
%>
<body bgcolor="#8C9AAA" class="bgDynamic">

<form action="./med_log_detail.jsp" method="post" name="form_">
 <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
<tr>
<td colspan="7" bgcolor="#697A8F" height="18" class="footerDynamic"><font color="#FFFFFF"><strong>&nbsp;&nbsp;::: MEDICATION LOG DETAILS :::</strong></font></td>
</tr> 
</table>
<%if (iTotalDose == 0 || iTakenDose<iTotalDose){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
  	<td width="3%" height="26" >&nbsp;</td>
  	<td width="43%" colspan="6"><%=WI.getStrValue(strErrMsg)%></td>
  	<td width="10%" >&nbsp;</td>
  </tr>
  <tr> 
      <td width="3%" height="26" >&nbsp;</td>
      <td width="48%" colspan="4"><strong>Total Dosage: </strong><%if (iTotalDose==0){%>Not Defined<%}else{%><%=iTotalDose%><%}%></td>
      <td width="44%"><strong>Dosage Taken: </strong><%if (vMedications!=null){%><%=(String)vMedications.elementAt(0)%><%}else{%>None<%}%></td>
    </tr>
  <tr> 
      <td width="3%" height="10" >&nbsp;</td>
      <td width="17%">&nbsp;</td>
      <td height="20" colspan="2">&nbsp;</td>
      <td width="11%">&nbsp;</td>
      <td width="44%">&nbsp;</td>
    </tr>
    <tr>
   <td >&nbsp;</td>
      <td >Dosage</td>
      <td  colspan="2" ><%=request.getParameter("dosage")%></td>
      <td>Date Taken </td>
      <td>&nbsp;<%
	strTemp = WI.fillTextValue("take_date");
	 if (strTemp == null || strTemp.length()==0)
        	  	strTemp = WI.getTodaysDate(1);
		%>
		<input name="take_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.take_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>
    </tr>
    
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Taken at</td>
      <td height="25" colspan="2" bgcolor="#FFFFFF"><select name="take_at">
          <option value="0">Home</option>
          <option value="1">Clinic</option>
        </select></td>
      <td bgcolor="#FFFFFF">Time Taken</td>
      <td bgcolor="#FFFFFF">&nbsp;<input type="text" name="take_time_hr" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("take_time_hr")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidHour();">
        :
        <input type="text" name="take_time_min" size="2" maxlength="2" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("take_time_min")%>"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="CheckValidMin();">
        :
        <select name="take_time_AMPM">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("take_time_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Assisted by : </td>
      <td height="25" colspan="4" bgcolor="#FFFFFF">
	 <%strTemp = WI.fillTextValue("assist_by");%>
     <input name="assist_by" type="text" size="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>">
     </td>
    </tr>
    <tr>
    <td colspan="6"><div align="center"><a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">Click to add entry</font></div></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td colspan="8" bgcolor="#FFFFFF"><hr size="1"></td>
    </tr>
</table>
<%}%>
<%	if (vMedications != null && vMedications.size()>0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
  	<tr bgcolor="#FFFFCA"> 
      <td height="25" colspan="6" class="thinborder"><div align="center" class="thinborder"><strong>MEDICATIONS TAKEN</strong></div></td>
    </tr>
    <tr>
    <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>Date Taken</strong></font></div></td>
    <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>Time Taken</strong></font></div></td>
    <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>Dosage</strong></font></div></td>
    <td width="18%" class="thinborder"><div align="center"><font size="1"><strong>Taken
    at
    </strong></font></div></td>
	<td width="18%" class="thinborder"><div align="center"><font size="1"><strong>Assisted
	by
	</strong></font></div></td>
	<td width="10%" class="thinborder">&nbsp;</td>
    </tr>
<%

	for (int i =1; i<vMedications.size(); i+=9){
%>	  
<%if (((String)vMedications.elementAt(i+8)).compareTo("1")==0)
		strTRCol = " bgcolor='#A9FFB6D'";
	else
		strTRCol = " bgcolor='#FFFFFF'";%>
	<tr<%=strTRCol%>>

<td class="thinborder"><font size="1"><%=(String)vMedications.elementAt(i+2)%></font></td>
<td class="thinborder"><font size="1"><%=CommonUtil.formatMinute((String)vMedications.elementAt(i+3))+':'+
	  CommonUtil.formatMinute((String)vMedications.elementAt(i+4))+astrAMPM[Integer.parseInt((String)vMedications.elementAt(i + 5))]%></td>
<td class="thinborder"><font size="1"><%=(String)vMedications.elementAt(i+1)%></font></td>
<td class="thinborder"><font size="1"><%=astrLoc[Integer.parseInt((String)vMedications.elementAt(i+7))]%></font></td>
<td class="thinborder"><font size="1"><%=(String)vMedications.elementAt(i+6)%></font></td>
<td class="thinborder"><a href='javascript:PageAction("0","<%=(String)vMedications.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a></td>
</tr>
<%}%>
  </table>
<%}else{%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<tr>
<td colspan="6" height="25"><div align="center"><strong>No Medications Taken</strong></div></td>
</tr>
</table>
<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr> 
      <td height="10">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
<input name = "dosage" type = "hidden"  value="<%=WI.fillTextValue("dosage")%>">
<input name = "interval" type = "hidden"  value="<%=WI.fillTextValue("interval")%>">
<input name = "total_dose" type = "hidden"  value="<%=WI.fillTextValue("total_dose")%>">
<input name="presc_index" type="hidden" value="<%=WI.fillTextValue("presc_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>