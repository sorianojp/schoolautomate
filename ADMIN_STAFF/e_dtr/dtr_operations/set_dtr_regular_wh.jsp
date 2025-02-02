<%@ page language="java" import="utility.*,java.util.Vector,eDTR.WorkingHour" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Set Regular working hours</title>
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

<style type="text/css">
	TD{
		font-size:11px;
	}

</style>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function showLunchBreak(){
	if (document.dtr_op.one_login.checked){
		document.getElementById("lunch_br").innerHTML =
		"<input name=\"lunch_break\" type=\"text\" size=\"3\" maxlength=\"3\"  "+
		"value=\"<%=WI.fillTextValue("lunch_break")%>\" class=\"textbox\" " +
		"onFocus=\"style.backgroundColor=\'#D3EBFF\'\" onBlur=\"style.backgroundColor=\'#FFFFFF\'\" " +
		" onKeypress=\" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;\"> Break (in Minutes)";

		document.getElementById("lbl_second_set").innerHTML = "Break Time <a href='javascript:showNote(1);'>NOTE</a>";

		document.dtr_op.logout_nextday.disabled = false;
//		document.dtr_op.pm_hr_fr.disabled = true;
//		document.dtr_op.pm_min_fr.disabled = true;
//		document.dtr_op.ampm_from1.disabled = true;
//		document.dtr_op.pm_hr_to.disabled = true;
//		document.dtr_op.pm_min_to.disabled = true;
//		document.dtr_op.ampm_to1.disabled = true;
	}else{
		document.getElementById("lunch_br").innerHTML = "";
		document.dtr_op.logout_nextday.disabled = true;
		document.getElementById("lbl_second_set").innerHTML = "Second Time In";
//		document.dtr_op.pm_hr_fr.disabled = false;
//		document.dtr_op.pm_min_fr.disabled = false;
//		document.dtr_op.ampm_from1.disabled = false;
//		document.dtr_op.pm_hr_to.disabled = false;
//		document.dtr_op.pm_min_to.disabled = false;
//		document.dtr_op.ampm_to1.disabled = false;
	}
}

function showNote(strShow){
	var iframe = document.getElementById('iframetop');
	var layer = document.getElementById("note_");

	if(strShow == '0'){
		layer.style.visibility = "hidden";
		iframe.style.display = 'none';
		layer.style.display = 'none';
	}else{
		layer.style.visibility = "visible";
		iframe.style.display = 'block';
		layer.style.display = 'block';
		iframe.style.width = layer.offsetWidth-5;
		iframe.style.left = layer.offsetLeft;
		iframe.style.top = layer.offsetTop;
		iframe.style.height = (layer.offsetHeight-5);
	}
}

	function AddRecords(){
		document.dtr_op.iAction.value = 1;
	}

	function ReloadPage(){
		document.dtr_op.submit();
	}

	function DeleteRecord(index){
		document.dtr_op.iAction.value = 0;
		document.dtr_op.info_index.value = index;
	}

	function EditRecord(index){
		document.dtr_op.iAction.value = 2;
		document.dtr_op.info_index.value = index;
		document.dtr_op.submit();
	}

	function PrepareToEdit(index){
		document.dtr_op.info_index.value = index;
		document.dtr_op.prepareToEdit.value =1;
	}

	function ViewRecord(index){
		if (index==null)
			document.dtr_op.iAction.value = 3;
		else
			document.dtr_op.iAction.value = 4;
	}

	function CancelEdit()
	{
	location = "./set_dtr_regular_wh.jsp";
	}

function viewList(table,indexname,colname,labelname,tablelist,
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=dtr_op&opner_form_field="+strFormField;

	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

-->
</script>
<body bgcolor="#D2AE72" onLoad="showLunchBreak();" class="bgDynamic">

<%
	String strErrMsg = "";
	String strTemp = new String();
	boolean bolProceed = true;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Set Regular working hour","set_dtr_regular_wh.jsp");
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
														"eDaily Time Record","WORKING HOURS MGMT",request.getRemoteAddr(),
														"set_dtr_regular_wh.jsp");
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
WorkingHour whRegular = new WorkingHour();
Vector vRegWorkingHour  = null;
	double dTime = 0d;
	int iHour = 0;
	int iMinute = 0;
	String strAMPM = " AM";
	String strTemp2 = null;
	String strHour = null;
	String strMinute = null;

String strPreparetoEdit=WI.fillTextValue("prepareToEdit");

if(WI.fillTextValue("iAction").compareTo("1") ==0) {
	vRegWorkingHour = whRegular.operateOnDefaultWH(dbOP,request,1);
	strTemp = whRegular.getErrMsg();
	if (strTemp == null)
		strTemp="New Working Hour added successfully";

}else if (WI.fillTextValue("iAction").compareTo("0") ==0){
	vRegWorkingHour = whRegular.operateOnDefaultWH(dbOP,request,0);
	strTemp = whRegular.getErrMsg();
	if (strTemp == null)
		strTemp="Working Hour Deleted successfully";

}else if (WI.fillTextValue("iAction").compareTo("2")==0){
	vRegWorkingHour = whRegular.operateOnDefaultWH(dbOP,request,2);
	strTemp = whRegular.getErrMsg();
	if (strTemp == null){
		strTemp = "Working Hour details edited Successfully";
		strPreparetoEdit = "0";
	}
}

if (strPreparetoEdit.equals("1")){
	vRegWorkingHour = whRegular.operateOnDefaultWH(dbOP,request,3, true);
	strTemp = whRegular.getErrMsg();
}

%>
<form action="./set_dtr_regular_wh.jsp" method="post" name="dtr_op">

  <table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        DTR OPERATIONS - SET REGULAR WORKING HOUR PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25"><strong><%=WI.getStrValue(strTemp)%></strong>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td height="30" colspan="2"><u><strong>New Regular Working Hour</strong></u></td>
    </tr>
 		<tr>
      <td>&nbsp;</td>
      <td colspan="2">Schedule name :
        <select name="sched_index" onChange="ReloadPage();">
        <%
					strTemp= WI.fillTextValue("sched_index");
				%>
        <option value="">Select schedule name</option>
        <%=dbOP.loadCombo("SCHED_INDEX","SCHED_NAME", " from edtr_wh_schedule order by SCHED_NAME",strTemp,false)%>
      </select>
			<%if(iAccessLevel > 1){%>
        <a href='javascript:viewList("edtr_wh_schedule","sched_index","SCHED_NAME",
																		 "SCHEDULE NAME", "EDTR_DEFAULT_WH", "sched_index",
																		 "and is_valid = 1","","sched_index");'><img src="../../../images/update.gif" border="0" ></a> <font size="1">click to add to the schedule</font>
			<%}%></td>
    </tr>

    <tr>
      <td width="4%">&nbsp;</td>
      <td colspan="2">
<%

	String[] astrConvertWeekDayInitial= {"S","M", "T", "W", "TH", "F", "SAT"};
	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
	  strTemp =astrConvertWeekDayInitial[Integer.parseInt((String)vRegWorkingHour.elementAt(0))];
	}else{
	  strTemp = WI.fillTextValue("work_day");
	}

%>
	  <input type="text" name="work_day" size="20" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		value ="<%=WI.getStrValue(strTemp)%>"
	  onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;"
	  OnKeyUP="javascript:this.value=this.value.toUpperCase();" <% if (vRegWorkingHour != null && vRegWorkingHour.size() > 0){ %> readonly <%}%>>
        <font size="1">(M-T-W-TH-F-SAT-S)</font></td>
    </tr>
    <tr>
      <td height="">&nbsp;</td>
      <td height="">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="">&nbsp;</td>
      <td width="21%" height="">First Time In </td>
      <td width="75%">
<%

	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
	 strTemp =(String)vRegWorkingHour.elementAt(1);
	}else{
	  strTemp = WI.fillTextValue("am_hr_fr");
	}
%>
	  <input name="am_hr_fr" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        :
<%

	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
	 strTemp =(String)vRegWorkingHour.elementAt(2);
	}else{
	  strTemp = WI.fillTextValue("am_min_fr");
	}
%>
        <input name="am_min_fr" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" 	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  <select name="ampm_from0">
<%
	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
	  strTemp = (String)vRegWorkingHour.elementAt(3);
	}else{
	  strTemp = WI.getStrValue(WI.fillTextValue("ampm_from0"),"0");
	}

if(strTemp.compareTo("0")==0){ %>
          <option value="0" selected>AM</option>
          <option value="1">PM</option>
<%}else{%>
          <option value="0">AM</option>
          <option value="1" selected>PM</option>
<%}%>
        </select>
        to
        <%
	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
	 strTemp =(String)vRegWorkingHour.elementAt(4);
	}else{
	  strTemp = WI.fillTextValue("am_hr_to");
	}
%>
        <input name="am_hr_to" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        :
<%

	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
	 strTemp =(String)vRegWorkingHour.elementAt(5);
	}else{
	  strTemp = WI.fillTextValue("am_min_to");
	}
%>
        <input name="am_min_to" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <select name="ampm_to0">
          <%
	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
	  strTemp = (String)vRegWorkingHour.elementAt(6);
	}else{
	  strTemp = WI.getStrValue(WI.fillTextValue("ampm_to0"),"0");
	}

if(strTemp.compareTo("0")==0){ %>
		<option value="0"selected>AM</option>
		<option value="1">PM</option>
<%}else{%>
		<option value="0">AM</option>
		<option value="1" selected>PM</option>
<%}%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td><label id="lbl_second_set">Second Time In</label>
			<iframe width="0" scrolling="no" height="0" frameborder="0" id="iframetop" style="position:absolute;"> </iframe>
			<div id="note_" style="position:absolute;visibility:hidden; width:500px;">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFCC">
				<tr>
					<td width="90%">If you enter valid break time range, then the Break (in Minutes) will be disregarded</td>
					<td width="10%" align="center"><a href="javascript:showNote('0');">HIDE</a></td>
				</tr>
			</table>
			</div></td>
      <td>
<%
	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
 	 strTemp = (String)vRegWorkingHour.elementAt(7);
 	 if(strTemp == null){
		 strTemp = (String)vRegWorkingHour.elementAt(16);
 			if(strTemp != null){
				dTime = Double.parseDouble(strTemp);
				if(dTime >= 12){
					strAMPM = "1";
					if(dTime > 12)
						dTime = dTime - 12;
				}else{
					strAMPM = "0";
				}

				iHour = (int)dTime;
				dTime = (dTime - iHour) * 60 + .02;
				iMinute = (int)dTime;
				strMinute = Integer.toString(iMinute);

				if(iHour == 0)
					iHour = 12;

				strHour = Integer.toString(iHour);
				strTemp = strHour;
			}
	 	}
	}else{
	  strTemp = WI.fillTextValue("pm_hr_fr");
	}
%>
	  <input name="pm_hr_fr" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" 	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        :
<%
	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
	 	strTemp = (String)vRegWorkingHour.elementAt(8) ;
	 	if(strTemp == null)
			 strTemp = strMinute;
	}else{
		strTemp = WI.fillTextValue("pm_min_fr");
	}
%>
		<input name="pm_min_fr" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>"
		class="textbox" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
    <select name="ampm_from1">
<%
	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
	  strTemp = (String)vRegWorkingHour.elementAt(9);
	 	if(strHour != null && strMinute != null)
			 strTemp = strAMPM;
	}else{
	  strTemp = WI.getStrValue(WI.fillTextValue("ampm_from1"),"0");
	}

if(strTemp.compareTo("0")==0){ %>
          <option value="0" selected>AM</option>
          <option value="1">PM</option>
<%}else{%>
          <option value="0">AM</option>
          <option value="1" selected>PM</option>
<%}%>
        </select>
        to
<%
	strAMPM = "0";
	strHour = null;
	strMinute = null;
	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
	 strTemp = (String)vRegWorkingHour.elementAt(10);
	 if(strTemp == null){
		 strTemp = (String)vRegWorkingHour.elementAt(17);
 			if(strTemp != null){
				dTime = Double.parseDouble(strTemp);
				if(dTime >= 12){
					strAMPM = "1";
					if(dTime > 12)
						dTime = dTime - 12;
				}else{
					strAMPM = "0";
				}

				iHour = (int)dTime;
				dTime = (dTime - iHour) * 60 + .02;
				iMinute = (int)dTime;
				strMinute = Integer.toString(iMinute);

				if(iHour == 0)
					iHour = 12;

				strHour = Integer.toString(iHour);
				strTemp = strHour;
			}
			//System.out.println("dTime " + dTime);
	 	}
	}else{
	  strTemp = WI.fillTextValue("pm_hr_to");
	}
%>
        <input name="pm_hr_to" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox"  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        :
<%

	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
 	  strTemp = (String)vRegWorkingHour.elementAt(11) ;
		if(strTemp == null)
		 strTemp = strMinute;
	}else{
	  strTemp = WI.fillTextValue("pm_min_to");
	}
%>
        <input name="pm_min_to" type="text" size="2" maxlength="2" value="<%=WI.getStrValue(strTemp)%>" class="textbox" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <select name="ampm_to1">
<%
	if (vRegWorkingHour != null && vRegWorkingHour.size() > 0) {
	  strTemp = (String)vRegWorkingHour.elementAt(12);
	 	if(strHour != null && strMinute != null)
			 strTemp = strAMPM;
	}else{
	  strTemp = WI.getStrValue(WI.fillTextValue("ampm_to1"),"0");
	}
if(strTemp.compareTo("0")==0){ %>
          <option value="0" selected>AM</option>
          <option value="1">PM</option>
<%}else{%>
          <option value="0">AM</option>
          <option value="1" selected>PM</option>
<%}%>
        </select>		</td>
    </tr>

    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
<% if (vRegWorkingHour != null && vRegWorkingHour.size() > 0
		&& vRegWorkingHour.elementAt(7) == null)
		strTemp = "checked";
	else
		strTemp = "";
		%>
  <input name="one_login" type="checkbox" value="1" <%=strTemp%> onClick="showLunchBreak()">
	  							check if Regular Hours requires only one login<label id="lunch_br"></label></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
	<% if (vRegWorkingHour != null && vRegWorkingHour.size() > 0
		&& ((String)vRegWorkingHour.elementAt(15)).equals("1"))
			strTemp = "checked";
		else
			strTemp = "";
		%>
      <td colspan="2"><input name="logout_nextday" type="checkbox" id="logout_nextday" value="1" disabled <%=strTemp%>>
        <font size="1">employee logout is on the next day</font></td>
    </tr>
<% if (iAccessLevel > 1) { %>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2"><div align="center">
 <%
    if(vRegWorkingHour == null || vRegWorkingHour.size() == 0) {%>
      <input type="image" src="../../../images/save.gif" width="48" height="28" onClick="AddRecords();">
      <font size="1">click to save changes </font>
	<%}else{
	%>  <a href='javascript:EditRecord("<%=(String)vRegWorkingHour.elementAt(13)%>");'><img src="../../../images/edit.gif" border="0"></a> <font size="1">click
        to save changes</font>

		<a href='javascript:CancelEdit();'><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
<%}%>
		  </div></td>
    </tr>
<%}%>
    <tr>
      <td>&nbsp;</td>
      <td height="30" colspan="2"><hr size="1" noshade>
	  <table width="95%" border="0" align="center" cellpadding="5" cellspacing="0">
          <tr bgcolor="#F5F5FC">
            <td height="25" colspan="4"><u><strong>Current Regular Working Hour</strong></u></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td width="14%" height="25"><strong>WEEK DAY</strong></td>
            <td width="43%" height="25"><strong>TIME</strong></td>
            <td width="26%" align="center"><strong> BREAK</strong> </td>
            <td width="17%" height="25" align="center"><strong>EDIT / DELETE</strong></td>
          </tr>
          <%
		  	vRegWorkingHour = whRegular.getDefaultWHIndex(dbOP,null,true, WI.fillTextValue("sched_index"));
	String[] astrConvertWeekDay= {"SUNDAY","MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"};
 	if(vRegWorkingHour!=null) {
	strAMPM = " AM";
		for (int i =0; i < vRegWorkingHour.size() ; i+=13){ %>
          <tr bgcolor="#FFFFFF">
            <td height="25"> <%=astrConvertWeekDay[Integer.parseInt((String)vRegWorkingHour.elementAt(i))] %></td>
<%
		strTemp = ((String)vRegWorkingHour.elementAt(i+1)) + " - " + ((String)vRegWorkingHour.elementAt(i+2));

		if ((String)vRegWorkingHour.elementAt(i+3) != null)
			strTemp +=  " / " + (String)vRegWorkingHour.elementAt(i+3) + " - "
						+ (String)vRegWorkingHour.elementAt(i+4);
		if (((String)vRegWorkingHour.elementAt(i+7)).equals("1"))
			strTemp +="(next day)";
%>
            <td height="25"><strong> <%=strTemp%></strong></td>
						<%
						strTemp = (String)vRegWorkingHour.elementAt(i+8);
						strTemp2 = (String)vRegWorkingHour.elementAt(i+9);
						if(strTemp != null && strTemp2 != null){
							dTime = Double.parseDouble(strTemp);
							if(dTime >= 12){
								strAMPM = " PM";
								if(dTime > 12)
									dTime = dTime - 12;
							}else{
								strAMPM = " AM";
							}

							iHour = (int)dTime;
							dTime = (dTime - iHour) * 60 + .02;
							iMinute = (int)dTime;
							if(iHour == 0)
								iHour = 12;

							strTemp = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;

							dTime = Double.parseDouble(strTemp2);
							if(dTime >= 12){
								strAMPM = " PM";
								if(dTime > 12)
									dTime = dTime - 12;
							} else {
								strAMPM = " AM";
							}

							iHour = (int)dTime;
							dTime = ((dTime - iHour) * 60) + .02;
 							iMinute = (int)dTime;
							if(iHour == 0)
								iHour = 12;

							strTemp2 = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;

							strTemp += " - " + strTemp2;
						}else{
							strTemp = (String)vRegWorkingHour.elementAt(i + 6);
 							if(Double.parseDouble(WI.getStrValue(strTemp,"0")) == 0)
								strTemp = "";
							else
								strTemp = WI.getStrValue(strTemp,""," min","");
						}
 						%>
            <td align="right"><%=strTemp%>&nbsp;</td>
            <td align="center">
              <% if (iAccessLevel >1){ %>
              <input type="image" src="../../../images/edit.gif" width="40" height="26" onclick='PrepareToEdit("<%=(String)vRegWorkingHour.elementAt(i+5)%>");'>
              <%}
if (iAccessLevel ==2){ %>
              <input type="image" src="../../../images/delete.gif" width="55" height="28" onclick='DeleteRecord("<%=(String)vRegWorkingHour.elementAt(i+5)%>");'>
              <%}%>            </td>
          </tr>
          <%} // end for loop
	}else{%> No Record of Default Regular Working Hour.
	<%}%>
        </table></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="iAction" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPreparetoEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
