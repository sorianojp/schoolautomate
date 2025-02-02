
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Billing Statement</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ReloadPage()
{
	document.bs_form.submit();
}
function ChangeDormLoc()
{
	document.bs_form.changeDormLoc.value="1";
	ReloadPage();
}
function FormProceed()
{
	document.bs_form.form_proceed.value = "1";
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	WebInterface WI = new WebInterface(request);
	MessageConstant mConst = new MessageConstant();
	
	String strErrMsg = null;
	String strTemp = null;String strTemp2 = null;
	boolean bolProceed = true;
    String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","Septmber","October","November","December"};

if(WI.fillTextValue("form_proceed").compareTo("1") ==0)
{%>
		<jsp:forward page="./obs_print.jsp" />
<%}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/Hostel Management-CHARGES- Billing statement","obs.jsp");
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
														"Hostel Management","CHARGES",request.getRemoteAddr(), 
														"obs.jsp");	
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
	
%>
<form name="bs_form" action="./obs.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="6" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
        OCCUPANT'S BILLING STATEMENT PAGE ::::<br>
        </strong></font></div></td>
    </tr>
	</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4"> &nbsp;&nbsp;&nbsp; </td>
    </tr>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="16%">Print by </td>
      <td width="23%"><select name="smt_type" onChange="ReloadPage();">
          <option value="0">Occupant</option>
          <%
strTemp = WI.fillTextValue("smt_type");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Location/Name</option>
          <%}else{%>
          <option value="1">Location/Name</option>
          <%}%>
        </select></td>
      <td width="57%">Year/Month :&nbsp; <input name="year_availed" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("year_availed")%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        <select name="month_availed">
          <option value="0">January</option>
          <%
strTemp = WI.fillTextValue("month_availed");
for(int i=1; i< 12; ++i){
	if(strTemp.compareTo(Integer.toString(i)) ==0)
	{%>
          <option value="<%=i%>" selected><%=astrConvertMonth[i]%></option>
          <%}else{%>
          <option value="<%=i%>"><%=astrConvertMonth[i]%></option>
          <%}
}%>
        </select></td>
    </tr>
    <%
if(WI.fillTextValue("smt_type").compareTo("1") != 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>ID Number </td>
      <td><input name="id" type="text" size="16" value="<%=WI.fillTextValue("id")%>" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td>&nbsp;</td>
    </tr>
    <%}else{%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Location/Name </td>
      <td><select name="location" onChange="ChangeDormLoc();">
          <option value="0">Select a location</option>
          <%
strTemp = " from FA_STUD_SCHFAC_DORM_LOC where is_del=0 order by LOCATION asc";
%>
          <%=dbOP.loadCombo("LOCATION_INDEX","LOCATION",strTemp, WI.fillTextValue("location"), false)%> 
        </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Room #/House # </td>
      <td colspan="2"> 
        <%//display only if a location is selected.
if(WI.fillTextValue("location").length()> 0 && WI.fillTextValue("location").compareTo("0") != 0){%>
        <select name="dorm_room">
          <option value="0">For All occupied room(s)</option>
          <%
//show all occupied  and partially occupied rooms for printing billing statement
		  
strTemp = " from FA_STUD_SCHFAC_DORM_LAYOUT where LOCATION_INDEX="+WI.fillTextValue("location")+
	" and is_del=0 and is_valid=1 and (room_status=1 or room_status=3)  order by room_no asc";
%>
          <%=dbOP.loadCombo("DORMITORY_INDEX","ROOM_NO",strTemp, WI.fillTextValue("dorm_room"), false)%> 
        </select>
        <%}%><br>
        <font size="1">If room not selected, billing statement will be printed 
        for all the occupants in selected location</font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <%}//end of displaying depending on smt_type%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><div align="center"><input type="image" src="../../../images/form_proceed.gif" onClick="FormProceed();"></a> 
          <font size="1">click to start printing</font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="changeDormLoc" value="0">
<input type="hidden" name="form_proceed" value="0">
</form> 
</body>
</html>
<%
dbOP.cleanUP();
%>