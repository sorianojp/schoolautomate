<%@ page language="java" import="utility.*,java.util.Vector,health.CTPreEnrollment" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Patient Health Status..</title>
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
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function TestTypeChange(strTestType){
	document.form_.testTypeChanged.value = "1";
	document.form_.testTypeValue.value = strTestType;
	this.SubmitOnce('form_');
}
function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	document.form_.testTypeChanged.value = "1";
	document.form_.printClicked.value = "";
	this.SubmitOnce('form_');
}
function PrintList(){
	document.form_.printClicked.value = "1";
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#8C9AAA" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;	
	
	if(WI.fillTextValue("printClicked").compareTo("1") == 0){%>
		<jsp:forward page="search_ct_print.jsp"/>
	<%return;}
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinical Test","search_ct.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Health Monitoring","Clinical Test",request.getRemoteAddr(),
														"search_ct.jsp");
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
	CTPreEnrollment CTPE = new CTPreEnrollment();
	Vector vRetResult = new Vector();
	Vector vTempStud = new Vector();
	Vector vPermStud = new Vector();
	vRetResult = null;
	int iTemp = 0;
	int iCountTemp = 0;
	int iCountPerm = 0;
	String strTempAddlVenue    = "";
    String strTempAddlTestDate = "";
 	
	if(WI.fillTextValue("proceedClicked").compareTo("1") == 0){		
		vRetResult = CTPE.operateOnSearchList(dbOP,request,Integer.parseInt(WI.fillTextValue("stud_type")));
		if(vRetResult == null)
			strErrMsg = CTPE.getErrMsg();
		else{
			vPermStud = (Vector)vRetResult.elementAt(0);
			vTempStud = (Vector)vRetResult.elementAt(1);					
		}
	}
		
//end of authenticaion code.
%>
<form method="post" name="form_" action="search_ct.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="28" colspan="4" bgcolor="#697A8F" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SEARCH CLINICAL TESTS PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr > 
      <td height="25">&nbsp;</td>
      <td width="22%" >Test Type:</td>
      <% strTemp = WI.fillTextValue("test_type");%>
      <td colspan="2" > <select name="test_type" onChange="javascript:TestTypeChange(<%=WI.fillTextValue("test_type")%>)">
          <option value="0">All</option>
          <%=dbOP.loadCombo("TEST_TYPE_INDEX","TEST_TYPE"," FROM HM_CT_TESTTYPE", strTemp, false)%> </select> </td>
    </tr>
    <tr > 
      <td width="1%" height="25"  >&nbsp;</td>
      <td >Test Code: </td>
      <% strTemp = WI.fillTextValue("test_code");%>
      <td colspan="2"> <select name="test_code">
          <option value="0">All</option>
          <% if(WI.fillTextValue("testTypeChanged").compareTo("1") == 0){ %>
          <%=dbOP.loadCombo("SCHED_INDEX","TEST_CODE",
		  " FROM HM_CT_SCHED where "+WI.getStrValue(WI.fillTextValue("test_type"),"TEST_TYPE_INDEX = "," and ","")+"IS_VALID = 1 and IS_DEL = 0",
		   strTemp, false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr > 
      <td height="25" >&nbsp;</td>
      <td height="25" >Student Type:</td>
      <td height="25" colspan="2" ><select name="stud_type">
          <% if(WI.fillTextValue("stud_type").compareTo("1") == 0){%>
          <option value="2">All</option>
          <option value="0">Permanent</option>
          <option value="1" selected>Temporary</option>
          <%}else if(WI.fillTextValue("stud_type").compareTo("0") == 0){%>
          <option value="2">All</option>
          <option value="0" selected>Permanent</option>
          <option value="1">Temporary</option>
          <%}else{%>
          <option value="2">All</option>
          <option value="0">Permanent</option>
          <option value="1">Temporary</option>
          <%}%>
        </select></td>
    </tr>
    <tr > 
      <td height="25" >&nbsp;</td>
      <td height="25" >Date of Test:</td>
      <td height="25" colspan="2" >From: 
        <input name="exam_date_fr" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("exam_date_fr" )%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.exam_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
        To: 
        <input name="exam_date_to" type="text" class="textbox" size="10" maxlength="10" value="<%=WI.fillTextValue("exam_date_to")%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.exam_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr > 
      <td height="10" >&nbsp;</td>
      <td height="10" colspan="3" >&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" >&nbsp;</td>
      <td height="25" ><div align="left"> &nbsp;&nbsp;&nbsp;&nbsp; <a href="javascript:ProceedClicked();"> 
          <img src="../../../images/form_proceed.gif" width="81" height="21" border="0"> 
          </a> </div></td>
      <% if(vTempStud != null && vPermStud != null){
		   if(vTempStud.size() > 1 || vPermStud.size() > 1){%>
      <td width="54%" height="25" ><div align="right">Number of Students Per Page: 
          <select name="num_stud_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_stud_page"),"20"));
				for(int i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
        </div></td>
      <td width="23%" ><a href="javascript:PrintList();"> <img src="../../../images/print.gif"  border="0"></a> 
        <font size="1">click to print list</font>&nbsp;&nbsp;&nbsp;</td>
      <%}}%>
    </tr>
    <tr > 
      <td height="25" colspan="4" ><hr size="1"></td>
    </tr>
  </table>   
  <%
  if(vTempStud != null){
  if (vTempStud.size() > 1){%>
  <table bgcolor="#FFFFFF" width="100%" border="0"  cellpadding="0" cellspacing="0" height="18">
  	<tr>
		<td height="18">&nbsp;</td>
	</tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFF9F"> 
      <td height="27" colspan="5"><div align="center"><strong><font  size="1">LIST 
          OF TEMPORARY STUDENTS</font></strong></div></td>
    </tr>
    <tr> 
      <td width="13%" height="25"><div align="center"><strong><font size="1">STUDENT ID</font></strong></div></td>
      <td width="26%"><div align="center"><strong><font size="1">STUDENT NAME</font></strong></div></td>
      <td width="24%"><div align="center"><strong><font size="1">TEST TYPE / CODE</font></strong></div></td>
      <td width="16%"><div align="center"><strong><font size="1">VENUE</font></strong></div></td>
      <td width="21%"><div align="center"><strong><font size="1">DATE OF TEST 
          - TIME</font></strong></div></td>
    </tr>
	    <% 		  
		  for(int iLoop = 0; iLoop < vTempStud.size(); iLoop += 8,iCountTemp++){%>
          <tr> 
            <td height="25"><div align="center"><font size="1"><%=(String)vTempStud.elementAt(iLoop)%></font></div></td>
            <td height="25"><font size="1">&nbsp;<%=WI.formatName((String)vTempStud.elementAt(iLoop+1),(String)vTempStud.elementAt(iLoop+2),(String)vTempStud.elementAt(iLoop+3),4)%></font></td>
            <td height="25"><font size="1">&nbsp;
			<%=(String)vTempStud.elementAt(iLoop+4)+" / "+(String)vTempStud.elementAt(iLoop+5)%>
			<%
			for(; (iLoop + 8) < vTempStud.size() ;){
			 if(((String)vTempStud.elementAt(iLoop)).compareTo((String)vTempStud.elementAt(iLoop + 8)) != 0)
					break;
			 strTempAddlVenue += (String)vTempStud.elementAt(iLoop + 6) +"<br>&nbsp; ";
			 strTempAddlTestDate += (String)vTempStud.elementAt(iLoop + 7) + "<br>&nbsp; ";%>
			 <br>&nbsp; <%=(String)vTempStud.elementAt(iLoop + 8 + 4)+" / "+(String)vTempStud.elementAt(iLoop + 8 +  5)%>
		     <%iLoop += 8;}%>
			</font></td>
            <td height="25"><font size="1">&nbsp; <%=strTempAddlVenue + (String)vTempStud.elementAt(iLoop+6)%></font></td>
            <td height="25"><font size="1">&nbsp; <%=strTempAddlTestDate + (String)vTempStud.elementAt(iLoop+7)%></font></td>
          </tr>
          <%
		  strTempAddlVenue = "";strTempAddlTestDate = "";
		  }%>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0"  cellpadding="0" cellspacing="0" height="18">
  	<tr>
		<td height="18"><strong><font size="1">TOTAL RESULT : <%=iCountTemp%></font></strong></td>
	</tr>
  </table>
  <%}}%>  
  <%if(vPermStud != null){
  if(vPermStud.size() > 1){%>
  <table bgcolor="#FFFFFF" width="100%" border="0"  cellpadding="0" cellspacing="0" height="18">
  	<tr>
		<td height="18">&nbsp;</td>
	</tr>
  </table> 
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	  	
          <tr bgcolor="#FFFF9F"> 
            <td height="27" colspan="5"><div align="center"><strong><font  size="1">LIST 
                OF PERMANENT STUDENTS</font></strong></div></td>
          </tr>
          <tr> 
            <td width="13%" height="25"><div align="center"><strong><font size="1">STUDENT 
                ID</font></strong></div></td>
            <td width="26%"><div align="center"><strong><font size="1">STUDENT 
                NAME</font></strong></div></td>
            <td width="24%"><div align="center"><strong><font size="1">TEST TYPE 
                - CODE</font></strong></div></td>
            <td width="16%"><div align="center"><strong><font size="1">VENUE</font></strong></div></td>
            <td width="21%"><div align="center"><strong><font size="1">DATE OF 
          TEST / TIME</font></strong></div></td>
          </tr>
          <% 		  
		  for(int iLoop = 0; iLoop < vPermStud.size(); iLoop += 8,iCountPerm++){%>
          <tr> 
            <td height="25"><div align="center"><font size="1"><%=(String)vPermStud.elementAt(iLoop)%></font></div></td>
            <td height="25"><font size="1">&nbsp;<%=WI.formatName((String)vPermStud.elementAt(iLoop+1),(String)vPermStud.elementAt(iLoop+2),(String)vPermStud.elementAt(iLoop+3),4)%></font></td>
            <td height="25"><font size="1">&nbsp;
			<%=(String)vPermStud.elementAt(iLoop+4)+" / "+(String)vPermStud.elementAt(iLoop+5)%>
			<%
			for(; (iLoop + 8) < vPermStud.size() ;){
			 if(((String)vPermStud.elementAt(iLoop)).compareTo((String)vPermStud.elementAt(iLoop + 8)) != 0)
					break;
			 strTempAddlVenue += (String)vPermStud.elementAt(iLoop + 6) +"<br>&nbsp; ";
			 strTempAddlTestDate += (String)vPermStud.elementAt(iLoop + 7) + "<br>&nbsp; ";%>
			 <br>&nbsp; <%=(String)vPermStud.elementAt(iLoop + 8 + 4)+" / "+(String)vPermStud.elementAt(iLoop + 8 +  5)%>
		     <%iLoop += 8;}%>
			</font></td>
            <td height="25"><font size="1">&nbsp; <%=strTempAddlVenue + (String)vPermStud.elementAt(iLoop+6)%></font></td>
            <td height="25"><font size="1">&nbsp; <%=strTempAddlTestDate + (String)vPermStud.elementAt(iLoop+7)%></font></td>
          </tr>
          <%
		  strTempAddlVenue = "";strTempAddlTestDate = "";
		  }%>
        </table>
		<table bgcolor="#FFFFFF" width="100%" border="0"  cellpadding="0" cellspacing="0" height="18">
  			<tr>
				<td height="18"><strong><font size="1">TOTAL RESULT : <%=iCountPerm%></font></strong></td>
			</tr>
  		</table>
        <%}}%>     
  <table width="100%">	
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input  type="hidden" name="testTypeChanged" value="">
  <input type="hidden" name="testTypeValue" value="">
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="printClicked" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
