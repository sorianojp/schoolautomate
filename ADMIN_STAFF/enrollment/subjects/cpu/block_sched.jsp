<%@ page language="java" import="utility.*, enrollment.SubjectSectionCPU,java.util.Vector" %>
<%

	DBOperation dbOP = null;

	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS-subject sectioning","block_sched.jsp");
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
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
TD{
	font-size:11px;
}
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function EditThis(strIndex)
{
	location = "./sched_edit.jsp?stub_code="+strIndex;
}
function ReloadPage() {
	this.SubmitOnce("form_");
}

</script>
<body bgcolor="#D2AE72">
<%
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","STATISTICS",request.getRemoteAddr(),
														"block_sched.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = null;
Vector vTemp = null;

int iCtr1 = 0;
int iCtr2 = 0;



float fTemp24HF = 0f;
float fTemp24HT = 0f;
int[] iTimeDataFr = null;
int[] iTimeDataTo = null;
String strTempDay = "";
String strTempRoom = "";
String strTempIndex = null;
String strTempSub = null;
String[] astrDay = {"S","M","T","W","TH","F","SAT"};
String[] astrAMPM = {"AM", "PM"};
String str12AMList = "";

String[] astrSemester = {"Summer", "First Semeter", "Second Semester","Third Semester"};
SubjectSectionCPU subSecCPU = new SubjectSectionCPU();

if (WI.fillTextValue("offering_yr_from").length()>0 && WI.fillTextValue("offering_yr_to").length()>0 && 
WI.fillTextValue("offering_sem").length()>0)
{
	if (WI.fillTextValue("section").length()==0) {
		vRetResult = subSecCPU.operateOnSectionList(dbOP, null,	WI.fillTextValue("offering_yr_from"),
													WI.fillTextValue("offering_yr_to"),WI.fillTextValue("offering_sem"),2);
	}
	else
	{
		vRetResult = subSecCPU.operateOnSectionList(dbOP, WI.fillTextValue("section"),
													WI.fillTextValue("offering_yr_from"),
													WI.fillTextValue("offering_yr_to"),WI.fillTextValue("offering_sem"),1);
	}
		
	if (vRetResult==null)
		strErrMsg = subSecCPU.getErrMsg();
}
%>
<form name="form_" action="./block_sched.jsp" method="post">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable">
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5"><div align="center"><strong><font color="#FFFFFF" size="2"> CLASS PROGRAM - BLOCK SECTION SCHEDULE</font></strong></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr> 
      <td height="25"></td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td height="25"></td>
      <td colspan="3"><font size="2">School offering year/term:</font> 
        <%
strTemp = WI.fillTextValue("offering_yr_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="offering_yr_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","offering_yr_from");DisplaySYTo("form_","offering_yr_from","offering_yr_to")'>
        to 
        <%
strTemp = WI.fillTextValue("offering_yr_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="offering_yr_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> &nbsp;&nbsp;&nbsp; 
	  <%
        strTemp = WI.fillTextValue("offering_sem");
		if(strTemp.length() ==0 )
			strTemp = (String)request.getSession(false).getAttribute("cur_sem");
        %>
	  <select name="offering_sem">
          <option value="1">1st Sem</option>
          <%
		if(strTemp.equals("2")){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.equals("0")){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="18"><font size="1">&nbsp;</font></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" width="2%"></td>
      <td width="12%"><strong>Section :</strong></td>
      <td width="24%">
      <input type="text" name="section" size="20" value="<%=WI.fillTextValue("section")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeypress="if(event.keyCode==39 || event.keyCode==34) event.returnValue=false;"></td>
      <td width="62%"><a href="javascript:ReloadPage();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr > 
      <td height="10" colspan="4">&nbsp;&nbsp;</td>
    </tr>
  </table>
	<%if (vRetResult != null && vRetResult.size()>0){
	for (iCtr1 = 0; iCtr1 < vRetResult.size(); iCtr1+=2){
	vTemp = (Vector)vRetResult.elementAt(iCtr1+1);
	if (vTemp!= null && vTemp.size()>0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="7" bgcolor="#DDDDDD" height="25"><strong>&nbsp;SECTION: 
		<%=(String)vRetResult.elementAt(iCtr1)%> - Subjects Load for 
		<%=astrSemester[Integer.parseInt(WI.getStrValue(WI.fillTextValue("offering_sem"),"0"))]%> , 
		<%=WI.fillTextValue("offering_yr_from")%> - <%=WI.fillTextValue("offering_yr_to")%></strong></td>
	</tr>
	<tr>
		
      <td width="7%" align="left" height="25">&nbsp;Stub</td>
		<td width="20%" align="left">Subject</td>
		<td width="18%">Time</td>
		<td width="10%">Days</td>
		<td width="10%">Room</td>
		<td width="28%" align="left">Teacher</td>
		<td width="7%">Credit</td>
	</tr>
	<tr>
		<td colspan="7"><hr size="0.5"></hr></td>
	</tr>
	<%
	for (iCtr2 = 0; iCtr2 < vTemp.size(); iCtr2+=13){
	strTempIndex = (String)vTemp.elementAt(iCtr2);%>
	<tr>
		
      <td height="25">&nbsp;<%=(String)vTemp.elementAt(iCtr2)%></td>
		<td><%=(String)vTemp.elementAt(iCtr2+2)%></td>
		<%
		strTempDay = "";
		strTempRoom = WI.getStrValue((String)vTemp.elementAt(iCtr2+9),"TBA");

	if (vTemp.elementAt(iCtr2+4)!=null && vTemp.elementAt(iCtr2+5) != null)
    {
    	strTempDay = astrDay[Integer.parseInt((String)vTemp.elementAt(iCtr2+6))];
    	fTemp24HF = Float.parseFloat((String)vTemp.elementAt(iCtr2+4));
	    fTemp24HT = Float.parseFloat((String)vTemp.elementAt(iCtr2+5));
	    
	    iTimeDataFr = comUtil.convert24HRTo12Hr(fTemp24HF);
		if (iTimeDataFr != null && iTimeDataFr[2]  == 1 && iTimeDataFr[0] != 12)
			iTimeDataFr[0] +=12;
			
	    iTimeDataTo = comUtil.convert24HRTo12Hr(fTemp24HT);
		if (iTimeDataTo != null && iTimeDataTo[2]  == 1 && iTimeDataTo[0] != 12)
			iTimeDataTo[0] +=12;	
			
	    if(iTimeDataFr == null || iTimeDataTo == null ||
			0f == fTemp24HF  ||  0f == fTemp24HT){
			
			if (str12AMList.length() == 0) 
				str12AMList = (String)vTemp.elementAt(iCtr2);
			else
				str12AMList += "," + (String)vTemp.elementAt(iCtr2);
			
		}
	   
	   
      while ((iCtr2+13)< vTemp.size() && 
      strTempIndex.equals(vTemp.elementAt(iCtr2+13)) &&
      vTemp.elementAt(iCtr2+4).equals(vTemp.elementAt(iCtr2+17)) &&
      vTemp.elementAt(iCtr2+5).equals(vTemp.elementAt(iCtr2+18)) &&
      ((vTemp.elementAt(iCtr2+8) == null && vTemp.elementAt(iCtr2+21)==null)  
      || (vTemp.elementAt(iCtr2+8) != null && vTemp.elementAt(iCtr2+21)!=null 
      && vTemp.elementAt(iCtr2+8).equals(vTemp.elementAt(iCtr2+21))) ))
      {
      	  strTempDay += astrDay[Integer.parseInt((String)vTemp.elementAt(iCtr2+19))];
      	  iCtr2+=13;
      }
	}
	
	if (vTemp.elementAt(iCtr2+4)!=null && vTemp.elementAt(iCtr2+5) != null   
			&& iTimeDataFr != null && iTimeDataTo != null){
		strTemp = comUtil.formatMinute(Integer.toString(iTimeDataFr[0]))
			+ comUtil.formatMinute(Integer.toString(iTimeDataFr[1])) + " - "
		  	+ comUtil.formatMinute(Integer.toString(iTimeDataTo[0]))  
			+ comUtil.formatMinute(Integer.toString(iTimeDataTo[1]));
	} else {
		strTemp = "TBA";
	}	
	  %>
	 <td><%=strTemp%></td>
     <td><%=WI.getStrValue(strTempDay,"TBA")%></td>
     <td><%=strTempRoom%></td>
     <td><%=(String)vTemp.elementAt(iCtr2+12)%></td>
     <td><%=(String)vTemp.elementAt(iCtr2+11)%></td>
	</tr>
	<%}%>
	</table>
	<%}%>
	<%}
	
	if (str12AMList.length() > 0) {
	%>
  <table width="100%">
    <tr>
      <td height="25" colspan="2" bgcolor="#F99797">
		&nbsp;<strong>Please check the time of this stub codes (12AM) : 
					<%=str12AMList%></strong>
	  </td>
    </tr>
  </table>	
	
	
	<%} // end show list of 12 Subjects
	} // end if vRetResult != null%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable2" bgcolor="#FFFFFF">
    <tr >
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
