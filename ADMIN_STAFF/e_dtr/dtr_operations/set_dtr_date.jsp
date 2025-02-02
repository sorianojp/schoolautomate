<%@ page language="java" import="utility.*,eDTR.CutoffDate,java.util.Vector" %>
<%
	String[] strColorScheme = CommonUtil.getColorScheme(7);
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
<script language="JavaScript">
<!--
function AddRecord()
{
	document.dtr_op.addRecord.value = "1";
	document.dtr_op.deleteRecord.value = "0";
	document.dtr_op.submit();
}

function DeleteRecord(info){
	document.dtr_op.addRecord.value = "0";
	document.dtr_op.deleteRecord.value = "1";
	document.dtr_op.info_index.value = info;
	document.dtr_op.submit();
}
-->
</script>
</head>

<body bgcolor="#D2AE72" class="bgDynamic">
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	int iTemp = 0;
	boolean bolProceed = true;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Set DTR cut-off dates","set_dtr_date.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(), 
														"set_dtr_date.jsp");	
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
CutoffDate setCutOffDate = new CutoffDate();
strTemp = WI.fillTextValue("addRecord");
if(strTemp.compareTo("1") ==0)
{
	if(setCutOffDate.addCutOffDate(dbOP,request))
		strErrMsg = "Pay Period Cutoff Saved successfully";
	else
		strErrMsg = setCutOffDate.getErrMsg();
}

strTemp = WI.fillTextValue("deleteRecord");
if(strTemp.compareTo("1") == 0){
	if (setCutOffDate.deleteCutOffDate(dbOP,request))
		strErrMsg = "Pay Period CutOff Deleted Successfully";
	else
		strErrMsg = setCutOffDate.getErrMsg();
}

Vector vDTRPeriodDetails = setCutOffDate.getCutOffDetail(dbOP, request);
String[] astrConvertPayPeriod = {"","First","Second","Third","Fourth","Fifth"};

%>	

<form action="./set_dtr_date.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      DTR OPERATIONS - SET DTR CUT-OFF DATE PAGE ::::</strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="21%" height="25">&nbsp;</td>
      <td height="25" colspan="2" align="center">Date
      <div align="center"></div></td>
      <td width="36%" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" rowspan="2"><table width="60%" height="69" border="1" cellpadding="5" cellspacing="0">
          <tr bgcolor="#FFFFFF"> 
            <td width="26%">FROM</td>
            <td width="31%" height="29">TO</td>
            <td width="43%" height="29">Pay Period</td>
          </tr>
          <tr bgcolor="#FFFFFF"> 
            <td>
			<select name="dtr_cut_off_from">
<%
strTemp = WI.getStrValue(WI.fillTextValue("dtr_cut_off_from"),"0");
iTemp = Integer.parseInt(strTemp);
for(int i=1; i<=31; ++i)
{
	if(iTemp == i){%>
	<option selected><%=CommonUtil.formatMinute(Integer.toString(i))%></option>
	<%}else{%>
	<option><%=CommonUtil.formatMinute(Integer.toString(i))%></option>
	<%}
}%>
           </select></td>
            <td height="25"> <select name="dtr_cut_off_to">
                <%
strTemp = WI.getStrValue(WI.fillTextValue("dtr_cut_off_to"),"0");
iTemp = Integer.parseInt(strTemp);
for(int i=1; i<=31; ++i)
{
	if(iTemp == i){%>
                <option selected><%=CommonUtil.formatMinute(Integer.toString(i))%></option>
                <%}else{%>
                <option><%=CommonUtil.formatMinute(Integer.toString(i))%></option>
                <%}
}%>
              </select> </td>
            <td height="25"><select name="dtr_cut_off_payperiod">
                <option value="1">First</option>
<%
strTemp = WI.getStrValue(WI.fillTextValue("dtr_cut_off_payperiod"),"0");
if(strTemp.compareTo("2") ==0){%>
                <option value="2" selected>Second</option>
<%}else{%>
                <option value="2">Second</option>
<%}if(strTemp.compareTo("3") ==0){%>
                <option value="3" selected>Third</option>
<%}else{%>
                <option value="3">Third</option>
<%}if(strTemp.compareTo("4") ==0){%>
                <option value="4" selected>Fourth</option>
<%}else{%>
                <option value="4">Fourth</option>
<%}%>              </select></td>
          </tr>
        </table></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2" align="center">
  		<%if(iAccessLevel > 1){%>
			<a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a><font size="1">click 
      to save changes</font>
			<%}%>
			</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
<% if (vDTRPeriodDetails.size() != 0) {%> 
  <table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#993300">
      <td height="25" colspan="4" align="center" bgcolor="#C7DAFE"><font color="#000000"><strong>LIST 
      OF PAY PERIODS</strong></font></td>
    </tr>
    <tr>
      <td width="37%" align="right"><strong>Pay Period</strong></td>
      <td width="17%" align="center"><strong>FROM</strong></td>
      <td width="16%" align="center"><strong>TO</strong></td>
      <td width="30%">&nbsp;</td>
    </tr>
<% 	for (int i=0 ; i <vDTRPeriodDetails.size();i+=4) {%>
    <tr>
      <td align="right"><strong>
        <%=astrConvertPayPeriod[Integer.parseInt((String)vDTRPeriodDetails.elementAt(i))]%></strong></td>
      <td align="center"><strong><%=(String)vDTRPeriodDetails.elementAt(i+1)%></strong></td>
      <td align="center"><strong><%=(String)vDTRPeriodDetails.elementAt(i+2)%></strong></td>
      <td>
	  	<%if(iAccessLevel == 2){%>
			<a href="javascript:DeleteRecord('<%=(String)vDTRPeriodDetails.elementAt(i+3)%>')"><img src="../../../images/delete.gif" border="0"></a>	  
			<%}%>
			</td>
    </tr>
    <% } %> 
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
  <input type="hidden" name ="info_index" value="<%=strTemp%>">
  <input type="hidden" name ="cutoff_from" value="">
  <input type="hidden" name ="cutoff_to" value="">
  <input type="hidden" name="addRecord" value="0">
  <input type="hidden" name="deleteRecord" value="0">
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>