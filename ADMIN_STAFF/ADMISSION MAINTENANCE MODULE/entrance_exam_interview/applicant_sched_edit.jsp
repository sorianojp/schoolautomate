<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function ReloadPage()
{
	document.form_.proceed_clicked.value = "1";
	document.form_.save_changes.value = "";
	document.form_.pageAction.value = "";
	this.SubmitOnce('form_');
}
function OpenSearch()
{
	var pgLoc = "../../../search/srch_stud_temp.jsp?opner_info=form_.temp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SaveChanges() 
{
    document.form_.proceed_clicked.value = "1";
	document.form_.save_changes.value = "1";
	this.SubmitOnce('form_');
}
function PageAction(strIndex,strAction){
	document.form_.sch_code.value = strIndex;	
	document.form_.pageAction.value = strAction;	
	document.form_.contact_info.value = "Not Available";
	document.form_.proceed_clicked.value = "1";
	this.SubmitOnce('form_');	
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,enrollment.OfflineAdmission,java.util.Vector"	%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vExamResults  = null;
	Vector vApplicantData = null;
	Vector vExamList = null;
	Vector vAddExam = null;		
	String strErrMsg = null;
	String strTemp = null;
	int iNumOfSubj = 0;
	int i = 0;	
	String [] strAppStat = {"Denied", "Approved", "Under further evaluation"};
	String [] astrConvTime={" AM"," PM"};
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW","applicant_sched_view.jsp");
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
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",request.getRemoteAddr(),
														"applicant_sched_view.jsp");
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
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	OfflineAdmission offAdd = new OfflineAdmission();
	int iResultSize  = 0;
	boolean bolSchedExist = false;
	
	if(WI.fillTextValue("pageAction").compareTo("5") == 0){
		if(!offAdd.autoScheduling(dbOP,request,WI.fillTextValue("temp_id"),""))
			strErrMsg = offAdd.getErrMsg();
		else
			strErrMsg = "Autoscheduling successful.";
	}
	else if(WI.fillTextValue("pageAction").compareTo("1") == 0){
		vAddExam = appMgmt.operateOnStudExamSched(dbOP,request,1);
		if(vAddExam == null)
			strErrMsg = appMgmt.getErrMsg();
		else
			strErrMsg = "Operation Successful";		
	}
	
	
	if(WI.fillTextValue("save_changes").equals("1")){
		iResultSize = Integer.parseInt(WI.getStrValue(request.getParameter("result_size"),"0"));
		if (iResultSize > 0){
			if(!appMgmt.saveUpdate(dbOP,request,(iResultSize/13)))
				strErrMsg = appMgmt.getErrMsg();
			else
				strErrMsg = "Schedule edited successfully.";			
		}
	}
	
	if(WI.fillTextValue("proceed_clicked").compareTo("1") == 0){	
		//view exams 
		vApplicantData = appMgmt.operateOnApplicantStatus(dbOP, request, 4);
		if (vApplicantData == null || vApplicantData.size() == 0)
			strErrMsg = appMgmt.getErrMsg();		
		else
		{
			i = Integer.parseInt(dbOP.mapOneToOther("NA_EXAM_NAME join NA_EXAM_SCHED on (NA_EXAM_NAME.EXAM_NAME_INDEX = " + 
													"  NA_EXAM_SCHED.EXAM_NAME_INDEX)"+
													" join NA_EXAM_SCHED_STUD on (NA_EXAM_SCHED.EXAM_SCHED_INDEX = " + 
													"  NA_EXAM_SCHED_STUD.EXAM_SCH_INDEX) "+
													" join NEW_APPLICATION on (NEW_APPLICATION.APPLICATION_INDEX = " + 
													"  NA_EXAM_SCHED_STUD.TEMP_STUD_INDEX)",
			   									    "TEMP_ID","'"+WI.fillTextValue("temp_id")+"'","count(MAIN_EXAM)",
													" and NA_EXAM_SCHED_STUD.IS_DEL = 0 and MAIN_EXAM = 1"));											
			
			iNumOfSubj = Integer.parseInt(dbOP.mapOneToOther("NA_EXAM_NAME","IS_DEL","0","count(MAIN_EXAM)"," and MAIN_EXAM = 0"));
			iNumOfSubj += i;						
			vExamResults = appMgmt.operateOnApplicantStatus(dbOP, request, 2);			
			if (vExamResults != null)
				iResultSize = vExamResults.size();	
				
			vExamList = appMgmt.operateOnExamSched(dbOP,request,4);			
			
		}
	}			
%>
<form name="form_" method="post" action="./applicant_sched_edit.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td width="91%" height="25" colspan="8"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
          EDIT APPLICANT SCHEDULE PAGE ::::</font></strong></div></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18" colspan="5"><font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td width=2%>&nbsp;</td>
      <td width="17%">School Year/ Term</td>
      <td colspan="3"> <% strTemp = WI.fillTextValue("sy_from");
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); 
		%> <input name="sy_from" type="text" class="textbox" size="4" maxlength="4"  value="<%=strTemp%>" 
		onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %> <input name="sy_to" type="text" class="textbox" size="4" maxlength="4" 
		  value="<%=strTemp%>" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        / 
        <select name="semester">
          <% strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 && WI.fillTextValue("page_value").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected=>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}
		  
		  if (!strSchCode.startsWith("CPU")) {
		  
		  if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  } // remove 3rd sem
		  %>
        </select> </td>
    </tr>
    <tr> 
      <td height="2" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Temporary ID </td>
      <td width= "19%"> <input name="temp_id" type="text" class="textbox" value="<%=WI.fillTextValue("temp_id")%>" size="16" maxlength="16"
         onfocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"' > 
      </td>
      <td width = 6%><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="56%"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
  <%  if (vApplicantData!=null){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="2">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="2">Applicant Name : <strong><%=WI.formatName((String)vApplicantData.elementAt(0)+" ", (String)vApplicantData.elementAt(1), (String)vApplicantData.elementAt(2),7)%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Date Applied : <strong><%=((String)vApplicantData.elementAt(3))%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <%	  
	  strTemp = WI.getStrValue((String)vApplicantData.elementAt(4));
	  strTemp += WI.getStrValue((String)vApplicantData.elementAt(5),"/","","");	  
	  %>
      <td height="25" colspan="2">Course/Major Applied : <strong><%=WI.getStrValue(strTemp,"Not Available")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="48%" height="25">Current Application Status : <strong> 
        <%if((String)vApplicantData.elementAt(6)!= null){%>
        <%=strAppStat[Integer.parseInt((String)vApplicantData.elementAt(6))]%> 
        <%}%>
        </strong></td>
      <td width="48%">Status Updated : <strong> 
        <%if((String)vApplicantData.elementAt(7)!= null){%>
        <%=((String)vApplicantData.elementAt(7))%> 
        <%}%>
        </strong></td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <%if((iResultSize/13) < iNumOfSubj){%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="8" align="center" class="thinborder"><strong><font color="#FFFFFF">LIST 
          OF UNSCHEDULED EXAMS</font></strong></td>
    </tr>
    <tr> 
      <td width="10%" height="25" align="center" class="thinborder"><strong><font size="1">
        EXAM </font></strong></td>
      <td width="9%" align="center" class="thinborder"><strong><font size="1">SCHEDULE 
        CODE</font></strong></td>
      <td width="9%" align="center" class="thinborder"><strong><font size="1">EXAM 
        DATE</font></strong></td>
      <td width="9%" align="center" class="thinborder"><strong><font size="1">START 
        TIME</font></strong></td>
      <td width="9%" align="center" class="thinborder"><strong><font size="1">DUR(mins)</font></strong></td>
      <td align="center" class="thinborder"><strong><font size="1">VENUE</font></strong></td>
      <td width="23%" align="center" class="thinborder"><strong><font size="1">CONTACT PERSON</font></strong></td>
      <td width="17%" align="center" class="thinborder"><strong><font size="1">ADD</font></strong></td>
    </tr>
	<% //if(((String)vExamList.elementAt(iIndex+4)).equals((String)vExamResults.elementAt(i+12))){
	   boolean bolCont = false;	   
	   
	   if (vExamList != null && vExamList.size() > 0 ) {
	   
	   for(int iIndex = 0;iIndex < vExamList.size();iIndex+=20){
	   	if(vExamResults != null){
		  for (i = 0;i<vExamResults.size();i+=13){
		  
		     if(((String)vExamList.elementAt(iIndex+4)).equals((String)vExamResults.elementAt(i+12))){
			 	bolCont = false;	
				break;
			 }
			 else
			 	bolCont = true;			 			 			 
		  }
		}
		else
			bolCont = true;		  
		if (bolCont){%>
			<tr> 
      	      <td height="25" align="center" class="thinborder"><font size="1">
   	          <%=(String)vExamList.elementAt(iIndex+19)%></font></td>
      	      <td height="25" align="center" class="thinborder"><font size="1"><%=(String)vExamList.elementAt(iIndex+5)%></font></td>
      	      <td height="25" align="center" class="thinborder"><font size="1"><%=(String)vExamList.elementAt(iIndex+7)%></font></td>
      	      <td align="center" class="thinborder"><font size="1"><%=CommonUtil.formatMinute((String)vExamList.elementAt(iIndex+8))+":"+ 
			  										    CommonUtil.formatMinute((String)vExamList.elementAt(iIndex+9))+" "+ 
														astrConvTime[Integer.parseInt((String)vExamList.elementAt(iIndex+10))]%>
    	        </font></td>
      	      <td height="25" align="center" class="thinborder"><font size="1"><%=(String)vExamList.elementAt(iIndex+6)%></font></td>
      	      <td align="center" class="thinborder"><font size="1"><%=(String)vExamList.elementAt(iIndex+12)%></font></td>
      	      <td align="center" class="thinborder"><font size="1"><%=(String)vExamList.elementAt(iIndex+13)%></font></td>
      	      <td align="center" class="thinborder">
      	        <a href="javascript:PageAction(<%=(String)vExamList.elementAt(iIndex)%>,1);"><img src="../../../images/add.gif"  border="0" height="25"></a></td>
			</tr>			
		<%bolSchedExist = true;}//if
		}//for(int iIndex = 0, i = 0;iIndex < vExamList.size();iIndex+=20)
	 } // if vExamList.size> 0  
		if(!bolSchedExist){%>
		<tr>
			<td height="25" colspan="98" align="center" class="thinborder"><strong>		  NO&nbsp; SCHEDULE&nbsp; AVAILABLE</strong></td>
		</tr>
		<%}%>    
  </table>
  <%}%>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
  	<tr>
		<td>&nbsp;</td>
  	</tr>
	<% if(vExamResults == null){%>
	<tr>
		<td><div align="center"><a href="javascript:PageAction(0,5);">Click here to autoschedule</a></div></td>
	</tr>
	<%}%>
  </table>  
  <%}  
  if (vExamResults !=null)
  {
  %>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="10" align="center" class="thinborder"><strong><font color="#FFFFFF">LIST 
        OF SCHEDULED EXAMS</font></strong></td>
    </tr>
    <tr> 
      <td width="16%" height="25" align="center" class="thinborder"><strong><font size="1"> 
        EXAM </font></strong></td>
      <td width="15%" align="center" class="thinborder"><strong><font size="1">SCHEDULE 
          CODE</font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">EXAM 
          DATE</font></strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">START 
          TIME</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">DUR<br>
      (mins)</font></strong></td>
      <td width="42%" colspan="5" class="thinborder"><strong><font size="1">&nbsp;&nbsp;&nbsp;CHANGE 
        TO:</font></strong></td>
    </tr>
 <%
 int iAppendName = 1;
 for (i = 0;i<vExamResults.size();){ %>
    <tr> 
      <td height="25" align="center" class="thinborder"><font size="1"><%=(String)vExamResults.elementAt(i)%></font></td>
      <td height="25" align="center" class="thinborder"><font size="1"><%=(String)vExamResults.elementAt(i+1)%></font></td>
      <td height="25" align="center" class="thinborder"><font size="1"><%=(String)vExamResults.elementAt(i+2)%></font></td>
      <td align="center" class="thinborder"><font size="1"><%=CommonUtil.formatMinute((String)vExamResults.elementAt(i+3))+':'+
	  CommonUtil.formatMinute((String)vExamResults.elementAt(i+4))+astrConvTime[Integer.parseInt((String)vExamResults.elementAt(i + 5))]%></font></td>
      <td height="25" align="center" class="thinborder"><font size="1"><%=((String)vExamResults.elementAt(i+6))%></font></td>
      <td colspan="5" class="thinborder">&nbsp;&nbsp;&nbsp; 
	 <% if (vExamList != null && vExamList.size() > 0) { %> 
	  <select name="course_index_<%=iAppendName%>" style="font-size:10px;font-weight:bold">
          <option value="0">Select New Schedule</option>
          <% int iCount = 1;
		     for(int iIndex = 0;iIndex < vExamList.size();iIndex+=20){
		  		if(((String)vExamList.elementAt(iIndex+4)).equals((String)vExamResults.elementAt(i+12))){					
		  %>
          <option value="<%=(String)vExamList.elementAt(iIndex)%>"><%=(String)vExamList.elementAt(iIndex+5)+" ::: "%> <%=(String)vExamList.elementAt(iIndex+7)+" ::: "%> <%=CommonUtil.formatMinute((String)vExamList.elementAt(iIndex+8))+":"%> <%=CommonUtil.formatMinute((String)vExamList.elementAt(iIndex+9))+""%> <%=astrConvTime[Integer.parseInt((String)vExamList.elementAt(iIndex+10))]%> </option>
          <%}	
		  }%>
        </select>
		 <%}%> 
		<input type="hidden" name="sch_code_<%=iAppendName%>" value="<%=(String)vExamResults.elementAt(i+1)%>">
<!--   Added codes for checking conflict starts here   -->		
		<input type="hidden" name="exam_date_<%=iAppendName%>" value="<%=(String)vExamResults.elementAt(i+2)%>">
		<input type="hidden" name="start_time_hr_<%=iAppendName%>" value="<%=(String)vExamResults.elementAt(i+3)%>">
		<input type="hidden" name="start_time_min_<%=iAppendName%>" value="<%=(String)vExamResults.elementAt(i+4)%>">
		<input type="hidden" name="start_time_period<%=iAppendName%>" value="<%=(String)vExamResults.elementAt(i+5)%>">
		<input type="hidden" name="duration_<%=iAppendName%>" value="<%=((String)vExamResults.elementAt(i+6))%>">		
<!--  Added codes for checking conflict ends here    -->		</td>
    </tr>
    <% i = i + 13;
	   iAppendName++;
   	} //for (int i = 0;i<vExamResults.size();)%>
  </table>
  <%}
  if (vExamResults !=null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	<tr> 
      <td height="25" colspan="3" valign="top"><strong><font color="#000099">NOTE : Please check schedules 
        for conflicts before saving.</font></strong></td>
    </tr>
    <tr> 
      <td width="50%"><div align="right">           
          <a href="javascript:SaveChanges();"><img src="../../../images/save.gif" border="0"></a><font size="1">Click 
          to save entries</font> &nbsp;&nbsp; </div></td>
      <td width="50%" colspan="2" >&nbsp; <a href="javascript:ReloadPage();"><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a><font size="1">Click 
        to cancel</font>	 </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2" >&nbsp;</td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" bgcolor="#B5AB73">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="proceed_clicked" value="">
<input type="hidden" name="save_changes" value="">
<input type="hidden" name="result_size" value="<%=iResultSize%>">
<input type="hidden" name="get_avail_sched" value="1"><!-- used in ApplicationMgmtto get available sched-->
<input type="hidden" name="pageAction" value="">

<input type="hidden" name="sch_code" value="">
<input type="hidden" name="contact_info" value="">

</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>