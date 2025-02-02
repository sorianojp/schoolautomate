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
function OpenSearch()
{
	var pgLoc = "../../../search/srch_stud_temp.jsp?opner_info=form_.temp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function OpenSearch2()
{
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.temp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ProceedClicked()
{
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function PageAction(strSchedIndex,strAction){
	document.form_.pageAction.value = strAction;
	document.form_.schedIndex.value = strSchedIndex;
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}
function PrintSchedule(studID) {	
	var pgLoc = "./ct_sched_print.jsp?temp_id="+studID;
	var win=window.open(pgLoc,"AdmissionSlip",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#8C9AAA" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	int iNumOfSubjects = 0;
	int iAppendName = 1;
	
    //add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinical Test","edit_ct_sched.jsp");
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
														"Health Monitoring","Clinical Test",request.getRemoteAddr(),
														"edit_ct_sched.jsp");
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
}//end of authenticaion code.

	CTPreEnrollment CTPE = new CTPreEnrollment();
	Vector vRetResult = new Vector();
	Vector vStudInfo = new Vector();
	Vector vUnScheduled = new Vector();
	Vector vScheduled = new Vector();
	Vector vStudSched = new Vector();
	vRetResult = null;
	vStudInfo = null;
	
	if(WI.fillTextValue("pageAction").compareTo("") != 0){
		vRetResult = CTPE.operateOnStudTestSched(dbOP,request,
		WI.fillTextValue("temp_id"),Integer.parseInt(WI.fillTextValue("pageAction")));
		if(vRetResult == null)
			strErrMsg = CTPE.getErrMsg();		
	}
	
	if(WI.fillTextValue("proceedClicked").compareTo("1") == 0){
		vStudInfo = CTPE.operateOnStudInfo(dbOP,request);				
		if(vStudInfo == null)
			strErrMsg = CTPE.getErrMsg();
		else{		    
		    vRetResult = CTPE.operateOnStudTestSched(dbOP,request,WI.fillTextValue("temp_id"),3);
			if(vRetResult != null){
				vUnScheduled = (Vector)vRetResult.elementAt(0);				
				vScheduled = (Vector)vRetResult.elementAt(1);
				vStudSched = (Vector)vRetResult.elementAt(2);				
			}
			else			
				strErrMsg = CTPE.getErrMsg();						
		}			
	}
%>
<form method="post" name="form_" action="edit_ct_sched.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="28" colspan="5" bgcolor="#697A8F" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EDIT STUDENT SCHEDULE PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3">&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr > 
      <td width="2%"  >&nbsp;</td>
      <td width="14%" >&nbsp;</td>
      <td colspan="3" >&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Student ID: </td>
      <td width="18%"> <input name="temp_id" type="text" class="textbox" value="<%=WI.fillTextValue("temp_id")%>" size="16" maxlength="16"
         onFocus="style.backgroundColor='#D3EBFF'" onBlur='style.backgroundColor="white"' > 
      </td>
      <td colspan="2"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a><font size="1">click 
        to search temporary student</font></td>
    </tr>
    <tr > 
      <td height="25" >&nbsp;</td>
      <td height="25" >&nbsp;</td>
      <td height="25" ><a href="javascript:ProceedClicked();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
      <td height="25" colspan="2" ><a href="javascript:OpenSearch2();"><img src="../../../images/search.gif" border="0"></a><font size="1">click 
        to search permanent student</font></td>
    </tr>
    <tr > 
      <td height="20" colspan="5"  bgcolor="#697A8F">&nbsp;</td>
    </tr>
    <%if (vStudInfo != null){%>
    <tr > 
      <td height="20" colspan="5" >&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">Name of Student: <%=(String)vStudInfo.elementAt(1)%> <input type="hidden" name="isTempStud" value="<%=(String)vStudInfo.elementAt(2)%>"></td>
      <%if(vStudSched != null){
	  if(vStudSched.size() > 1){%>
	  <td width="42%"><div align="right">&nbsp
	  <a href="javascript:PrintSchedule('<%=WI.fillTextValue("temp_id")%>');">
	  <img src="../../../images/print.gif"  border="0">
	  </a>
	  <font size="1">click 
          to print schedule</font></div></td>
	   <%}}%>	  
    </tr>
    <tr > 
      <td height="18" colspan="5" ><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <% if(vRetResult != null){
	if(vRetResult.size() < 4){%>
	<tr>      
	  <td>&nbsp;</td>	 
    </tr>
	<%}else{%>
    <tr> 
      <td height="90"><table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
          <tr bgcolor="#FFFF9F"> 
            <td height="27" colspan="2"><div align="center"><strong><font  size="1">ADD 
                TEST SCHEDULES</font></strong></div></td>
          </tr>
          <tr> 
            <td width="17%" height="25"><div align="center"><strong><font size="1">TEST 
                TYPE</font></strong></div></td>
            <td>&nbsp;&nbsp;&nbsp; <strong><font size="1">AVAILABLE SCHEDULES 
              : </font></strong></div> <div align="center"><strong></strong></div></td>
          </tr>
          <%if(vUnScheduled != null){
		  iAppendName = 1;
		  int iIndex = 0;		  
		  for(int iLoop = 3;iLoop < vRetResult.size() ;iLoop+=2,iAppendName++){%>
          <tr> 
            <td height="25"><div align="center"><font size="1"><%=(String)vRetResult.elementAt(iLoop)%></font></div></td>
            <td height="25">&nbsp;&nbsp;&nbsp; <select name="avail_sched_<%=iAppendName%>" style="font-size:10px;font-weight:bold">
                <option value="0">Select Schedule</option>
                <%
			     for(iIndex = 0;iIndex < vUnScheduled.size();iIndex+=19){
			  		if(((String)vUnScheduled.elementAt(iIndex+1)).equals((String)vRetResult.elementAt(iLoop+1))){					
		 	    %>
                <option value="<%=(String)vUnScheduled.elementAt(iIndex)%>"><%=(String)vUnScheduled.elementAt(iIndex+3)+" ::: "%> <%=(String)vUnScheduled.elementAt(iIndex+4)+" ::: "%> <%=CommonUtil.formatMinute((String)vUnScheduled.elementAt(iIndex+5))+":"%> <%=CommonUtil.formatMinute((String)vUnScheduled.elementAt(iIndex+6))+""%> <%=(String)vUnScheduled.elementAt(iIndex+7)+" - "%> <%=CommonUtil.formatMinute((String)vUnScheduled.elementAt(iIndex+10))+":"%> <%=CommonUtil.formatMinute((String)vUnScheduled.elementAt(iIndex+11))+""%> <%=(String)vUnScheduled.elementAt(iIndex+12)+" ::: "%> <%=(String)vUnScheduled.elementAt(iIndex+14)%></option>
                <%}}%>
              </select> <div align="center"> </div></td>
          </tr>
          <%}}%>
        </table></td>
    </tr>
	<tr > 
      <td height="18"> <div align="center"> <a href="javascript:PageAction(0,5);">Click 
          to schedule automatically</a> <a href="javascript:PageAction(<%=iAppendName%>,1)"> 
          <img src="../../../images/add.gif"  border="0"></a><font size="1">click
          to add event</font> <a href="javascript:ProceedClicked();"> <img src="../../../images/cancel.gif" width="51" height="26" border="0"> 
          </a><font size="1">click to cancel</font> </div></td>
    </tr>
	<%}}%>    
  </table>
  <% if(vStudSched != null){
  if(vStudSched.size() > 0){%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#FFFF9F"> 
      <td height="27" colspan="6"><div align="center"><strong><font  size="1">EDIT 
          TEST SCHEDULES</font></strong></div></td>
    </tr>
    <tr> 
      <td width="10%" height="25"><div align="center"><strong><font size="1">TEST 
          TYPE</font></strong></div></td>
      <td width="16%"><div align="center"><strong><font size="1">TEST CODE</font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">DATE OF TEST</font></strong></div></td>
      <td width="12%"><div align="center"><strong><font size="1">TIME</font></strong></div></td>
      <td width="41%"><div align="center"><strong></strong></div>
        <div align="left"><strong><font size="1">&nbsp; CHANGE TO:</font></strong></div></td>
      <td width="8%"><div align="center"><strong><font size="1">DELETE</font></strong></div></td>
    </tr>
	<%iAppendName = 1;
	for(int iLoop = 0; iLoop < vStudSched.size(); iLoop+=19){%>
    <tr> 
      <td height="25"><div align="center"><font size="1"><%=(String)vStudSched.elementAt(iLoop+2)%></font></div></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vStudSched.elementAt(iLoop+3)%></font></div></td>
      <td height="25"><div align="center"><font size="1"><%=(String)vStudSched.elementAt(iLoop+4)%></font></div></td>
      <td height="25"><div align="center"><font size="1"><%=CommonUtil.formatMinute((String)vStudSched.elementAt(iLoop+5))+':'+
												   CommonUtil.formatMinute((String)vStudSched.elementAt(iLoop+6))+' '+
												   ((String)vStudSched.elementAt(iLoop+7))+" - "+  
												   CommonUtil.formatMinute((String)vStudSched.elementAt(iLoop+10))+':'+
												   CommonUtil.formatMinute((String)vStudSched.elementAt(iLoop+11))+' '+
												   (String)vStudSched.elementAt(iLoop+12)%></font></div></td>
      <td height="25"><div align="center"></div>
        &nbsp; <select name="sched_<%=iAppendName%>" style="font-size:10px;font-weight:bold">
		<option value="0">Select New Schedule</option>			
		  <%
		     for(int iIndex = 0;iIndex < vScheduled.size();iIndex+=19){
		  		if(((String)vScheduled.elementAt(iIndex+1)).equals((String)vStudSched.elementAt(iLoop+1))){					
		  %>
          <option value="<%=(String)vScheduled.elementAt(iIndex)%>"><%=(String)vScheduled.elementAt(iIndex+3)+" ::: "%> <%=(String)vScheduled.elementAt(iIndex+4)+" ::: "%> <%=CommonUtil.formatMinute((String)vScheduled.elementAt(iIndex+5))+":"%> <%=CommonUtil.formatMinute((String)vScheduled.elementAt(iIndex+6))+""%> <%=(String)vScheduled.elementAt(iIndex+7)%> </option>
          <%}
		  }%>
        </select> 
		<input type="hidden" name="sched_index_<%=iAppendName%>" value="<%=(String)vStudSched.elementAt(iLoop)%>">
		<input type="hidden" name="exam_date_<%=iAppendName%>" value="<%=(String)vStudSched.elementAt(iLoop+4)%>">
		<input type="hidden" name="start_time_<%=iAppendName%>" value="<%=(String)vStudSched.elementAt(iLoop+8)%>">
		<input type="hidden" name="end_time_<%=iAppendName%>" value="<%=(String)vStudSched.elementAt(iLoop+13)%>">
		</td>		
      <td height="25"><div align="center">
	  <a href="javascript:PageAction(<%=(String)vStudSched.elementAt(iLoop)%>,0)">
	  <img src="../../../images/delete.gif" border="0">
	  </a>
	  </div></td>
    </tr>
	<% iNumOfSubjects++;
	   iAppendName++;
	}%>
  </table>
  <%}}%>
  <table  width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr >
      <td height="18" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr > 
      <td height="25" colspan="9" bgcolor="#FFFFFF"><div align="center">		
	  <%if(vScheduled != null){
	  		if(vScheduled.size() > 0){%>	    
	  	    <a href="javascript:PageAction(<%=iNumOfSubjects%>,2);">          
      	    <img src="../../../images/edit.gif" width="40" height="26" border="0">
			</a><font size="1">click to edit event</font>
			<a href="javascript:ProceedClicked();">  
       	   <img src="../../../images/cancel.gif" width="51" height="26" border="0">
			</a><font size="1">click to cancel</font> 
	  <%}}%>       
		</div></td>
    </tr>
    <tr > 
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
	<%}%>
  </table>
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="pageAction" value="">
  <input type="hidden" name="schedIndex" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
