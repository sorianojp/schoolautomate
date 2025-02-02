<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,
								hr.HRInfoLeave"%>
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
TD{
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

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_education.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"leave_apply.jsp");
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
Vector vEmpRec = null;
Vector vEditResult = null;
boolean bNoError = false;
boolean bolSetEdit = false;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

HRInfoLeave hrPx = new HRInfoLeave();

strTemp = WI.fillTextValue("emp_id");

if (strTemp.length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
}

Vector vAllowedLeave = hrPx.getAllowedLeave(dbOP, request);

boolean bolMyHome = WI.fillTextValue("my_home").equals("1");


vRetResult = hrPx.operateOnLeave(dbOP, request, 4);

String[] astrConvertAMPM={" AM"," PM"};
String[] astrCurrentStatus ={"Disapproved", "Approved", "Pending/On-process",
							 "Recommends Approval by Vice-President", 
							 "Recommends Approval by President"};

%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./leave_apply.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"  bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" size="2" ><strong>:::: 
          HR : APPLY/UPDATE REQUEST(S) PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
    <tr> 
      <td width="36%" height="25">&nbsp;&nbsp;Employee ID : 
        <input name="emp_id" type= "text" class="textbox" value="<%=WI.getStrValue(strTemp)%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="7%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="57%"><input type="image" src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;AY 
        / SEM&nbsp;: 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
		
        <input name="sy_from" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp)%>" size="4" maxlength="4" onKeyUp="DisplaySYTo('form_', 'sy_from', 'sy_to')">

<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>		
        -&nbsp; <input name="sy_to" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp)%>" size="4" maxlength="4" readonly="yes"> &nbsp;&nbsp;
        <select name="semester">
		<option value="1"> 1st Sem</option>
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");

	if (strTemp.equals("2")) {
%>		<option value="2" selected> 2nd Sem</option>
<%}else{%>
	<option value="2"> 2nd Sem</option>
<%} if ( strTemp.equals("3")){%>
		<option value="3" selected> 3rd Sem</option>
<%}else{%>
		<option value="3"> 3rd Sem</option>
<%}if ( strTemp.equals("0")){%>
		<option value="0" selected> Summer</option>
<%}else{%>		
		<option value="0"> Summer</option>
<%}%>
        </select>
		</td>
    </tr>
    <tr> 
      <td height="34" colspan="3"><strong><font color="#FF0000" size="2">&nbsp;&nbsp;</font></strong></td>
    </tr>
  </table>
<%  if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="100%" height="25"><img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="95%" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle">&nbsp;</td>
          </tr>
        </table>
        <table bgcolor="#FFFFFF" width="95%" border="0" cellspacing="0" cellpadding="0">
          <tr bgcolor="#F4F4FF"> 
            <td width="2%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
            <td colspan="2" ><strong><font size="2">Available Leave</font></strong></td>
            <td width="55%"><strong><font size="2">Apply for</font></strong> </td>
          </tr>
          <tr bgcolor="#F4F4FF"> 
            <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
            <td width="2%">&nbsp;</td>
            <td width="33%"> <% if (vAllowedLeave != null && vAllowedLeave.size() > 0) {%> <table width="90%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
                <% for(int i = 0 ; i < vAllowedLeave.size(); i+=3) {%>
                <tr> 
                  <td width="60%" class="thinborder">&nbsp;<%=(String)vAllowedLeave.elementAt(i+1)%></td>
                  <td width="40%" height="25" align="right" class="thinborder">&nbsp;<strong><%=CommonUtil.formatFloat(((Double)vAllowedLeave.elementAt(i+2)).doubleValue(),false)%> day(s)&nbsp;</strong></td>
                </tr>
                <%}%>
              </table>
              <%}%> </td>
            <td valign="top"> <%
	if (vEditResult != null) 
		strTemp = (String)vEditResult.elementAt(2);
	else
		strTemp = WI.fillTextValue("benefit_index");
%> <select name="benefit_index" onChange="ChangeLeave()">
                <option value="0"> Leave without Pay </option>
<% if (vAllowedLeave != null && vAllowedLeave.size() > 0){
		for (int i= 0; i < vAllowedLeave.size(); i+=3){
		
/*		uncomment this line to remove leave benefit with zero balance		
		if(((Double)vAllowedLeave.elementAt(i+2)).doubleValue() <.01d)
				continue;
*/
			if (((String)vAllowedLeave.elementAt(i)).equals(strTemp)){%>
                <option selected value="<%=(String)vAllowedLeave.elementAt(i)%>"> 
                <%=(String)vAllowedLeave.elementAt(i+1)%></option>
                <%}else{%>
                <option value="<%=(String)vAllowedLeave.elementAt(i)%>"> 
                <%=(String)vAllowedLeave.elementAt(i+1)%></option>
                <%		}
	} // end for loop
} // vaAllowedLeave  != null %>
              </select> </td>
          </tr>
          <tr bgcolor="#F4F4FF"> 
            <td height="18" bgcolor="#FFFFFF">&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td valign="top">&nbsp;</td>
          </tr>
        </table>
        <% if (WI.fillTextValue("cur_leave_text").toUpperCase().indexOf("MATERNITY") != -1) {  %> <table width="95%" border="0"  cellpadding="0" cellspacing="0">
          <tr> 
            <td>&nbsp;</td>
            <td colspan="3" bgcolor="#B9B9DD"><table width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr> 
                  <td width="24%" >&nbsp;Present No . of children :</td>
                  <td width="74%" colspan="2"><strong> <%=dbOP.mapOneToOther("HR_INFO_SP_CHILD", "user_index",(String)vEmpRec.elementAt(0), "count(*)", 
			" and relation_index = 1 and is_del =0")%></strong></td>
                </tr>
                <tr> 
                  <td >&nbsp;No. of Previous Deliveries: </td>
                  <td colspan="2"><%=dbOP.mapOneToOther("HR_INFO_SP_CHILD", "user_index",(String)vEmpRec.elementAt(0), "count(*)", " and relation_index = 1 and is_del =0")%></td>
                </tr>
              </table></td>
          </tr>
          <tr> 
            <td width="2%">&nbsp;</td>
            <td bgcolor="#B9B9DD">&nbsp;</td>
            <td bgcolor="#B9B9DD">&nbsp;</td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td bgcolor="#B9B9DD">&nbsp;Expected date of delivery : <br> <font color="#000000"> 
              &nbsp; 
<%	if (vEditResult != null) 
		strTemp = WI.getStrValue((String)vRetResult.elementAt(7));
	else
		strTemp = WI.fillTextValue("expected_date");
%>
              <input name="expected_date" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','expected_date','/')" 
		  value ="<%=strTemp%>" size="10" maxlength="10" 
		  onKeyUp="AllowOnlyIntegerExtn('form_','expected_date','/')">
              <a href="javascript:show_calendar('form_.expected_date');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
              <img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></font></td>
            <td width="65%" bgcolor="#B9B9DD">Start date of two(2) weeks pre-delivery 
              leave of absence :<br> &nbsp; 
<%	if (vEditResult != null) 
		strTemp = WI.getStrValue((String)vRetResult.elementAt(8));
	else
		strTemp = WI.fillTextValue("pre_delivery");
%> <input name="pre_delivery" type= "text"  class="textbox" 
		   onFocus="style.backgroundColor='#D3EBFF'" 
		   onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','pre_delivery','/')" 
		   onKeyUp="AllowOnlyIntegerExtn('form_','pre_delivery','/')" value = "<%=strTemp%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('form_.pre_delivery');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td colspan="3" bgcolor="#B9B9DD">&nbsp;</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td colspan="3" bgcolor="#B9B9DD">&nbsp;Number of days of maternity 
              leave : 
              <%
		if (vEditResult != null)
			strTemp = (String)vEditResult.elementAt(9);
		else
			strTemp = WI.fillTextValue("maternity_days");
	
		if (strTemp.length() == 0)
			strTemp = "60"; // default value for maternity leave		
	%> <input name="maternity_days" type= "text" class="textbox"  onFocus="style.backgroundColor='#D3EBFF'"
    onBlur="style.backgroundColor='white'; AllowOnlyInteger('form_','maternity_days')"  
	value="<%=strTemp%>" size="3" maxlength="3" onKeyUp="AllowOnlyInteger('form_','maternity_days')"> 
            </td>
          </tr>
          <tr> 
            <td height="15">&nbsp;</td>
            <td colspan="3" bgcolor="#B9B9DD">&nbsp;</td>
          </tr>
        </table>
        <%}%> <table width="95%" border="0"  cellpadding="2" cellspacing="0">
          <tr> 
            <td width="2%">&nbsp;</td>
            <td width="20%" rowspan="3" bgcolor="#F0EFF1" >Date(s) of Leave</td>
            <td width="13%" bgcolor="#F0EFF1" >(FROM) </td>
            <td colspan="2" bgcolor="#F0EFF1" >		
<% if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(10);
	else
		strTemp = WI.fillTextValue("ldatefrom");
%> <input name="ldatefrom" type= "text" class="textbox"  value="<%=strTemp%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','ldatefrom','/')"  
				onKeyUp="AllowOnlyIntegerExtn('form_','ldatefrom','/')"> <a href="javascript:show_calendar('form_.ldatefrom');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              Time 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(11));
	else
		strTemp = WI.fillTextValue("hrfrom");
%>
	<input  value="<%=strTemp%>" name="hrfrom" type= "text" class="textbox" 
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','hrfrom')"  
			  size="2" maxlength="2"
			  onKeyUp="AllowOnlyInteger('form_','hrfrom')">
              : 
<% if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(12);
	else
		strTemp = WI.fillTextValue("fmin");
		
	if (strTemp.length() < 2) strTemp = "";
%> 
	<input  value="<%=strTemp%>" name="fmin" type= "text" class="textbox"  size="2"
			   maxlength="2" onFocus="style.backgroundColor='#D3EBFF'" 
			   onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','fmin')"
			   onKeyUp="AllowOnlyInteger('form_','fmin')" > <select name="frAMPM">
                <option value="0">AM</option>
<% if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(13);
	else
		strTemp = WI.fillTextValue("frAMPM");
						
				if (strTemp.equals("1")) {%>
                <option value="1" selected>PM</option>
                <%}else{%>
                <option value="1">PM</option>
                <%}%>
              </select></td>
          </tr>
          <tr> 
            <td width="2%">&nbsp;</td>
            <td bgcolor="#F0EFF1">&nbsp;</td>
            <td colspan="2" bgcolor="#F0EFF1">
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(20));
	else
		strTemp = WI.fillTextValue("onedate");
	
	if (strTemp.equals("1"))
		strTemp = "checked";
	else
		strTemp = "";
%> <input name="onedate" type="checkbox" value="1" <%=strTemp%>> 
              <font size="1">Check if leave is less than a day</font></td>
          </tr>
          <tr> 
            <td width="2%">&nbsp;</td>
            <td bgcolor="#F0EFF1" > (TO) </td>
            <td colspan="2" bgcolor="#F0EFF1" >
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(14));
	else
		strTemp = WI.fillTextValue("ldateto");
%> <input name="ldateto" type= "text"  class="textbox" 
			onfocus="style.backgroundColor='#D3EBFF'" value="<%=strTemp%>" size="10" maxlength="10" 
			onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','ldateto','/')" 
			onKeyUp="AllowOnlyIntegerExtn('form_','ldateto','/')"> <a href="javascript:show_calendar('form_.ldateto');" title="Click to select date" 
		   onmouseover="window.status='Select date';return true;" 
		   onmouseout="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> Time 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(15));
	else
		strTemp = WI.fillTextValue("hrto");
%> 
		<input  value="<%=strTemp%>" name="hrto" type= "text" class="textbox"  
		onFocus="style.backgroundColor='#D3EBFF'"  size="2" maxlength="2"
		onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','hrto')" 
		onKeyUp="AllowOnlyInteger('form_','hrto')"> : 
<% if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(16);
	else
		strTemp = WI.fillTextValue("minto");
	
		if (strTemp.length() < 2) strTemp = "";
%> 
		<input  value="<%=strTemp%>" name="minto" type= "text" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" size="2" maxlength="2"
		onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','minto')"
		onKeyUp="AllowOnlyInteger('form_','minto')" > 
        <select name="toAMPM">
                <option value="0">AM</option>
                <%
	if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(17);
	else
		strTemp = WI.fillTextValue("toAMPM");				
				if (strTemp3.compareTo("1") == 0) {
%>
                <option value="1" selected>PM</option>
                <%}else{%>
                <option value="1">PM</option>
                <%}%>
              </select></td>
          </tr>
          <tr> 
            <td height="39">&nbsp;</td>
            <td colspan="3" valign="bottom" bgcolor="#FFFFFF" >No. of days/hrs 
              applied <strong>: 
<%
	if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(22);
	else
		strTemp = WI.fillTextValue("days_applied");				
%>
              <input  value="<%=strTemp%>" name="days_applied" type= "text" class="textbox" 
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','days_applied')" 
			  onKeyUp="AllowOnlyFloat('form_','days_applied')" size="3" maxlength="3">
              days</strong><font color="#FF0000"><strong> or 
<%
	if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(21);
	else
		strTemp = WI.fillTextValue("hours_applied");
	
	if (strTemp.equals("0")) strTemp = "";				
%>
              <input  value="<%=strTemp%>" name="hours_applied" type= "text" class="textbox" 
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','hours_applied')"
			   onKeyUp="AllowOnlyFloat('form_','hours_applied')" size="3" maxlength="3">
              </strong></font><strong>hrs </strong></td>
            <td width="40%" valign="bottom" bgcolor="#FFFFFF" >Date Filed : 
<% if (vEditResult != null) 
		strTemp = WI.getStrValue((String)vEditResult.elementAt(3));
	else
		strTemp = WI.fillTextValue("datefiled");
	
	if(strTemp.length()  == 0) 
		strTemp = WI.getTodaysDate(1);
%> <input name="date_filed" type= "text"  class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" size="10" maxlength="10"
	  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_filed','/')" 
	  onKeyUp="AllowOnlyIntegerExtn('form_','date_filed','/')" value="<%=strTemp%>"> 
	  <a href="javascript:show_calendar('form_.datefiled');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
          <tr> 
            <td height="114">&nbsp;</td>
            <td colspan="4" bgcolor="#FFFFFF" >Explanation/Reason : <br> 
<% if (vEditResult != null) 
		strTemp = WI.getStrValue((String)vEditResult.elementAt(23));
	else
		strTemp = WI.fillTextValue("reason");
%> <textarea name="reason" cols="64" rows="3"  class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea> 
            </td>
          </tr>
        </table>
        <table width="100%" border="0" cellpadding="2" cellspacing="0">
          <tr> 
            <td height="10" colspan="4"><hr size="1"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="3" valign="bottom"><strong><u><font size="2">Contact 
              info while on leave: </font></u></strong></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td width="12%" height="25">Address</td>
            <td width="86%" height="25" colspan="2"> 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(4));
	else
		strTemp = WI.fillTextValue("caddress");
%> <input value="<%=strTemp%>" name="caddress" type="text" size="64" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Tel. No.</td>
            <td height="25" colspan="2"> 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(5));
	else
		strTemp = WI.fillTextValue("contact_tel");
%> <input value="<%=strTemp%>"  name="contact_tel" type="text" 
			size="25"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" ></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Cell No.</td>
            <td height="25" colspan="2"> 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(6));
	else
		strTemp = WI.fillTextValue("contact_mobile");
%> <input value="<%=strTemp%>" name="contact_mobile" type="text" size="25"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
          </tr>
        </table>
        <% if (!bolMyHome){%> 
        <table width="100%" border="0" cellpadding="5" cellspacing="0">
          <tr> 
            <td height="25" colspan="3"><hr size="1"></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25" colspan="2" valign="bottom">Recommending Approval 
              by Dean/Head:</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td width="36%" height="25">
			<select name="head_approved" onChange="UpdateReqStatus()">
                <option value="2">Pending</option>
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(28));
	else
		strTemp = WI.fillTextValue("head_approved");
		
	if (strTemp.equals("1")) {
%>
                <option value="1" selected>Approved</option>
                <%}else{%>
                <option value="1">Approved</option>
                <%} if (strTemp.equals("0")) {%>
                <option value="0" selected>Disapproved</option>
                <%}else{%>
                <option value="0">Disapproved</option>
                <%} if (strTemp.equals("3")) {%>
                <option value="" selected>Not Required</option>
                <%}else{%>
                <option value="">Not Required</option>
                <%}%>
              </select> 
              <!--			  
			   <select name="head_approved_option">
                <option value="1">With Pay</option>
                <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(0),"0");
	else
		strTemp = WI.fillTextValue("head_approved_option");
		
		if (strTemp.equals("0")) {%>
                <option value="0" selected>Without Pay</option>
                <%}else{%>
                <option value="0">Without Pay</option>
                <%}%>
              </select>
-->
            </td>
            <td height="25">Date : 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(35));
	else
		strTemp = WI.fillTextValue("head_date");
%> <input name="head_date" type="text" class="textbox"
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','head_date','/')" 
			  onKeyUp="AllowOnlyIntegerExtn('form_','head_date','/')" value = "<%=strTemp%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('form_.head_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2" valign="bottom"> Approval by Vice-President 
              concerned : </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25"> <select name="vp_approved" onChange="UpdateReqStatus()">
                <option value="2">Pending</option>
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(29),"0");
	else
		strTemp = WI.fillTextValue("vp_approved");
		
		if (strTemp.equals("1")) {%>
                <option value="1" selected>Approved</option>
                <%}else{%>
                <option value="1">Approved</option>
                <%}if (strTemp.equals("0")){%>
                <option value="0" selected>Disapproved</option>
                <%}else{%>
                <option value="0">Disapproved</option>
                <%}if (strTemp.equals("3")){%>
                <option value="" selected>Not Required</option>
                <%}else{%>
                <option value="">Not Required</option>
                <%}%>
              </select> 
              <!--			  
			   <select name="vp_approved_option">
                <option value="1">With Pay</option>
                <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(0),"0");
	else
		strTemp = WI.fillTextValue("vp_approved_option");
		
		if (strTemp.equals("0")) {%>
                <option value="0" selected>Without Pay</option>
                <%}else{%>
                <option value="0">Without Pay</option>
                <%}%>
              </select>
-->
            </td>
            <td width="62%">Date : 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(37));
	else
		strTemp = WI.fillTextValue("vp_date");
%> <input name="vp_date" type="text" class="textbox"  value = "<%=strTemp%>"
  			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','vp_date','/')" 
			  onKeyUp="AllowOnlyIntegerExtn('form_','vp_date','/')" size="10" maxlength="10" > 
              <a href="javascript:show_calendar('form_.vp_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom">President's Approval: </td>
            <td>&nbsp;</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom"> <select name="pres_approved"  onChange="UpdateReqStatus()">
                <option value="2">Pending</option>
                <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(30),"0");
	else
		strTemp = WI.fillTextValue("pres_approved");
		
		if (strTemp.equals("1")){%>
                <option value="1" selected>Approved</option>
                <%}else{%>
                <option value="1">Approved</option>
                <%}if (strTemp.equals("0")){%>
                <option value="0" selected>Disapproved</option>
                <%}else{%>
                <option value="0">Disapproved</option>
                <%}if (strTemp.equals("3") ){%>
                <option value="" selected>Not Required</option>
                <%}else{%>
                <option value="">Not Required</option>
                <%}%>
              </select> 
              <!--			  
			  <select name="pres_approved_option">
                <option value="1">With Pay</option>
                <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(0),"0");
	else
		strTemp = WI.fillTextValue("pres_approved_option");
		
		if (strTemp.equals("1")){%>
                <option value="0" selected>Without Pay</option>
                <%}else{%>
                <option value="0">Without Pay</option>
                <%}%>
              </select>
-->
            </td>
            <td>Date : 
              <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(37));
	else
		strTemp = WI.fillTextValue("pres_date");
%> <input name="pres_date" type="text" class="textbox" value="<%=strTemp%>"
   			  onFocus="style.backgroundColor='#D3EBFF'" size="10" maxlength="10" 
			  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','pres_date','/')" 
			  onKeyUp="AllowOnlyIntegerExtn('form_','pres_date','/')"> <a href="javascript:show_calendar('form_.pres_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
            </td>
          </tr>
          <tr> 
            <td height="10" colspan="3"><hr size="1"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">Subsitute : <font size="1">(type lastname)</font> 
              <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="16" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px" onKeyUp = "AutoScrollList('form_.starts_with','form_.substitute',true);"> 
              <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(24));
	else
		strTemp = WI.fillTextValue("substitute");
%> <select name="substitute">
                <option value="" >Select Substitute </option>
                <%=dbOP.loadCombo("user_index","lname +'&nbsp;' + fname as emp_name",
				" FROM USER_TABLE WHERE ((AUTH_TYPE_INDEX <>4 and AUTH_TYPE_INDEX<>6) or AUTH_TYPE_INDEX is null) and is_valid = 1 and is_del =0  order by lname  ",strTemp,false)%> </select> <font size="1">(select Emp. ID)</font></td>
          </tr>
          <tr> 
            <td height="10" colspan="3"><hr size="1"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2"><u> <font size="2"><strong>Request Status:</strong></font></u> 
            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2"> <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(31));
	else
		strTemp = WI.fillTextValue("leave_appl_status");
%> <select name="leave_appl_status">
                <option value="2">Pending/On-process</option>
		<% if (strTemp.equals("3")){%>
                <option value="3" selected>Recommends Approval by Vice-President</option>
		<% }else{%>
                <option value="3">Recommends Approval by Vice-President</option>
		<%} if (strTemp.equals("4")){%>
                <option value="4" selected>Recommends Approval by President</option>
		<% }else{%>
                <option value="4" >Recommends Approval by President</option>
		<%} if (strTemp.equals("1")){%>
                <option value="1" selected>Approved</option>
		<% }else{%>	
                <option value="1">Approved</option>
		<%} if (strTemp.equals("0")){%>
                <option value="0" selected>Disapproved</option>
		<% }else{%>	
                <option value="0">Disapproved</option>	
		<%}%>
              </select> 
<!--
<select name="leave_appl_status_opt">
                <option>N/A</option>
                <option>With Pay</option>
                <option>Without Pay</option>
              </select>
-->
            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">Date of Request Status Update : 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(38));
	else
		strTemp = WI.fillTextValue("date_status");
		
		if (strTemp.length() == 0) {
			strTemp = WI.getTodaysDate(1);
		}
%> <input name="date_status"  type= "text" class="textbox"  value="<%=strTemp%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_status','/')"  
				onKeyUp="AllowOnlyIntegerExtn('form_','date_status','/')"> <a href="javascript:show_calendar('form_.date_status');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">Remarks : <br> 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(39));
	else
		strTemp = WI.fillTextValue("request_remarks");
%> <textarea name="request_remarks" cols="48" rows="3" class="textbox"
			 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
          </tr>
          <tr bgcolor="#FDEEEA">
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2"><strong><font color="#0000FF">UPDATE ONLY 
              THIS PORTION WHEN EMPLOYEE RETURNS FOR WORK:</font></strong></td>
          </tr>
          <tr bgcolor="#FDEEEA"> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">RETURN DATE :
              <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(25));
	else
		strTemp = WI.fillTextValue("date_return");
%> <input name="date_return"  type= "text" class="textbox"  value="<%=strTemp%>" 
			 size="10" maxlength="10" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','date_return','/')"  
				onKeyUp="AllowOnlyIntegerExtn('form_','date_return','/')"> <a href="javascript:show_calendar('form_.date_return');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;RETURN TIME : 
              <% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(32));
	else
		strTemp = WI.fillTextValue("hr_ret");
%> <input name="hr_ret" type= "text" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','hr_ret')" 
			onKeyUp=" AllowOnlyInteger('form_','hr_ret')"  value="<%=strTemp%>" size="2" maxlength="2">
              : 
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(33));
	else
		strTemp = WI.fillTextValue("min_ret");
		
		if (strTemp.length() <2) strTemp = "";
%> <input  value="<%=strTemp%>" name="min_ret" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','min_ret')" onKeyUp="AllowOnlyInteger('form_','min_ret')" size="2" maxlength="2"> 
              <select name="ampm_ret">
                <option value="0">AM</option>
<% if (vEditResult != null)
		strTemp = WI.getStrValue((String)vEditResult.elementAt(34));
	else
		strTemp = WI.fillTextValue("ampm_ret");
%>               <% if (strTemp.equals("1")) {%>
                <option value="1" selected>PM</option>
                <%}else{%>
                <option value="1">PM</option>
                <%}%>
              </select></td>
          </tr>
          <tr bgcolor="#FDEEEA"> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">Actual No. days/hrs<strong>: 
              <%
	if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(26);
	else
		strTemp = WI.fillTextValue("actual_days");
		
	if (strTemp.equals("0")) strTemp = "";
%>
              <input  value="<%=strTemp%>" name="actual_days" type= "text" class="textbox" 
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','actual_days')" 
			  onKeyUp="AllowOnlyFloat('form_','actual_days')" size="2" maxlength="2">
              days</strong><font color="#FF0000"><strong> or 
              <%
	if (vEditResult != null)
		strTemp = (String)vEditResult.elementAt(27);
	else
		strTemp = WI.fillTextValue("actual_hours");
	if (strTemp.equals("0")) strTemp = "";						
%>
              <input  value="<%=strTemp%>" name="actual_hours" type= "text" class="textbox" 
			  onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white';AllowOnlyFloat('form_','actual_hours')"
			   onKeyUp="AllowOnlyFloat('form_','actual_hours')" size="2" maxlength="2">
              </strong></font><strong>hrs &nbsp;&nbsp;<font color="#FF0000"> 
              <input type="checkbox" name="checkbox" value="checkbox">
              CHECK TO UPDATE LEAVE CREDITS</font></strong></td>
          </tr>
        </table>
        <%}  // end if not bol my home
	else
 {}
%> <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="2%" height="51">&nbsp;</td>
            <td width="98%" valign="bottom"><div align="center"> 
                <% if (iAccessLevel > 1){
		if(vEditResult == null  || vEditResult.size() == 0) { %>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                <font size="1">click to save entries</font> 
                <%}else{%>
                <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
                <font size="1">click to save changes</font> <a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'> 
                <img src="../../../images/cancel.gif" border="0"></a> <font size="1">click 
                to cancel and clear entries</font> 
                <%}}%>
              </div></td>
          </tr>
        </table>
        <br> <% if (vRetResult != null && vRetResult.size() > 0) {%> 
        <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr> 
            <td height="25" colspan="9" bgcolor="#F2EDE6" class="thinborder"><div align="center"><strong>LIST 
                OF APPLIED LEAVES </strong></div></td>
          </tr>
          <tr> 
            <td width="10%" height="25" class="thinborder"><font size="1"><strong>&nbsp;Date 
              Filed</strong></font></td>
            <td width="13%" class="thinborder"><font size="1"><strong> &nbsp;Type 
              of Leave</strong></font></td>
            <td width="16%" class="thinborder"><div align="center"><font size="1"><strong> 
                Date Fr (Time) ::<br>
                Date To (Time)</strong></font></div></td>
            <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>Days 
                (Hours) <br>
                Applied</strong></font></div></td>
            <td width="12%" class="thinborder"><font size="1"><strong>&nbsp;Current 
              Status </strong></font></td>
            <td width="12%" class="thinborder"><font size="1"><strong> &nbsp;Date 
              (Time) Return </strong></font></td>
            <td width="8%" class="thinborder"><font size="1"><strong>Actual Days 
              (Hours)</strong></font></td>
            <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>View 
                Details</strong></font></div></td>
            <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>Options</strong></font></div></td>
          </tr>
          <% for (int i =0 ; i < vRetResult.size() ; i+=45) {%>
          <tr> 
            <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
            <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+42)%></td>
            <%
				strTemp = (String)vRetResult.elementAt(i+10);
				if ((String)vRetResult.elementAt(i+11) != null){
					strTemp += "(" + (String)vRetResult.elementAt(i+11)  + " : " +
								(String)vRetResult.elementAt(i+12) +
								astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+13))] + 
								")";
				}
				
				strTemp +=  WI.getStrValue((String)vRetResult.elementAt(i+14)," -  ", "","");

				if ((String)vRetResult.elementAt(i+15) != null){
					strTemp += "(" + (String)vRetResult.elementAt(i+15)  + " : " +
								(String)vRetResult.elementAt(i+16) +
								astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+17))] + 
								")";
				}
				
			%>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <%
				strTemp ="";
				if (!((String)vRetResult.elementAt(i+22)).equals("0"))
					strTemp = (String)vRetResult.elementAt(i+22);
				if (!((String)vRetResult.elementAt(i+21)).equals("0"))
					strTemp += "(" + (String)vRetResult.elementAt(i+21) + ")";				
			%>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <td class="thinborder">&nbsp;<%=astrCurrentStatus[Integer.parseInt((String)vRetResult.elementAt(i+31))]%></td>
            <%
				strTemp =WI.getStrValue((String)vRetResult.elementAt(i+25));
				if ((String)vRetResult.elementAt(i+32) != null)
					strTemp += "(" + (String)vRetResult.elementAt(i+32) + " : " 
						 + (String)vRetResult.elementAt(i+33) + " " +  
						 astrConvertAMPM[Integer.parseInt((String)vRetResult.elementAt(i+34))]					  
						 + ")";				
			%>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <%
				if (!((String)vRetResult.elementAt(i+26)).equals("0")) {
					strTemp =(String)vRetResult.elementAt(i+26);
				}
				if (!((String)vRetResult.elementAt(i+27)).equals("0")) {
					strTemp += "(" + (String)vRetResult.elementAt(i+27) + ")";
				}
			%>
            <td class="thinborder">&nbsp;<%=strTemp%></td>
            <td class="thinborder"><div align="center"><img src="../../../images/view.gif" width="40" height="31"></div></td>
            <td class="thinborder"> <% if (iAccessLevel > 1) {%> <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
              <% if (iAccessLevel == 2) {%> <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
              <% 	} // end iAccessLevel ==2
			 }else{%>
              N/A 
              <%}%> </td>
          </tr>
          <%} // end for loop %>
        </table>
        <%} %> </td>
    </tr>
  </table>
<% } %>
   <table cellpadding="0" cellspacing="0" width="100%" bgcolor="#FFFFFF"> 
	<tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">


</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
