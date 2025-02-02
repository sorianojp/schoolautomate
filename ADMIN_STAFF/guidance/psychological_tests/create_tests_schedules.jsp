<%@ page language="java" import="utility.*, osaGuidance.*, java.util.Vector"%>
<%

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null )
	strSchCode = "";
	
boolean bolIsUB = strSchCode.startsWith("UB");

WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript"  src ="../../../jscript/td.js"></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}
function OpenSearch()
{

	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.admin_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function AddStudent(strPsyRef) {
	var pgLoc = "./schedule_stud.jsp?psy_index="+strPsyRef;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
</script>
</head>
<%
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./create_tests_schedules_print.jsp" />
	<%}
	
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	

	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS","create_tests_schedules.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	int iTemp = 0;
	int iSearchResult = 0;
	String [] astrConvTime={" AM"," PM"};


	GDPsychologicalTest PsychTest = new GDPsychologicalTest();
	
	strTemp = WI.fillTextValue("page_action");

	
	if(strTemp.length() > 0) {
		if(PsychTest.operateOnPsyTestSched(dbOP, request, Integer.parseInt(strTemp)) != null ){
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = PsychTest.getErrMsg();
	}
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = PsychTest.operateOnPsyTestSched(dbOP, request, 3);	
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = PsychTest.getErrMsg();
	}

	vRetResult = PsychTest.operateOnPsyTestSched(dbOP, request, 4);
	if (vRetResult == null && strErrMsg==null)
		strErrMsg = PsychTest.getErrMsg();
	else
		iSearchResult = PsychTest.getSearchCount();
		
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./create_tests_schedules.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING - CREATE PSYCHOLOGICAL TESTS SCHEDULES PAGE 
          ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    </tr>
    <tr> 
      <td height="30" width="5%">&nbsp;</td>
      <td width="18%">School Year</td>
      <td valign="middle" width="18%">
	<%
		strTemp = WI.fillTextValue("sy_from");
		if (vEditInfo != null && vEditInfo.size()>0)
		  strTemp = (String)vEditInfo.elementAt(1);      		
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); 
	%> 
	<input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox" 
		onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		onKeyPress= "if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"	
		onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
    <%
		strTemp = WI.fillTextValue("sy_to");
		if (vEditInfo != null && vEditInfo.size()>0)
		  strTemp = (String)vEditInfo.elementAt(2);		  
		if(strTemp.length() ==0)
			strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); 
	%> 
	<input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
      </td>
      <td width="5%" valign="middle">Term </td>
      <td width="15%" valign="middle">
      <%
	  	strTemp = WI.fillTextValue("semester");
	    if (vEditInfo != null && vEditInfo.size()>0)
		      strTemp = WI.getStrValue((String)vEditInfo.elementAt(3),"");
     	else
      %>
      <select name="semester" style="font-size:11px">
		<option value="">N/A</option>
          <%if(strTemp.compareTo("0") ==0){%>
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
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}%>
        </select> </td>
      <td width="39%" valign="middle"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
<%if (WI.fillTextValue("sy_from").length()>0 || WI.fillTextValue("sy_to").length()>0){%>
    <tr> 
      <td height="19" colspan="6"><hr size="1"></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>Schedule Code</td>
      <td colspan="4" valign="middle">
      <%if (vEditInfo != null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(6);
      else
	      strTemp = WI.fillTextValue("exam_code");  %> <input name="exam_code" type="text" size="16" maxlength="32"
	  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Test Name</td>
      <td colspan="4" valign="middle">
      <%if (vEditInfo != null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(4);
      else
	      strTemp = WI.fillTextValue("test_index");%>
		<select name="test_index">
          <option value="">Select test</option>
		<%=dbOP.loadCombo("test_name_index","test_name"," from gd_psytest_name where is_valid = 1 order by test_name", strTemp, false)%>
    </select>
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Administered by <font size="1">(Employee ID)</font></td>
      <td width="20%" height="30" valign="middle">
      <%if (vEditInfo != null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(14);
      else
	      strTemp = WI.fillTextValue("admin_id");%>
	      <input name="admin_id" type="text" size="32" maxlength="64" value="<%=strTemp%>" 
	    class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
      <td colspan="3" valign="middle"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" hspace="0" vspace="0" border="0"></a></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Date Test Given</td>
      <td height="30" colspan="4" valign="middle">
      <%
      if (vEditInfo != null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(8);
      else
	      strTemp = WI.fillTextValue("exam_date");%>
      <input name="exam_date" type="text" class="textbox" size="10" maxlength="10" value="<%=strTemp%>" readonly="yes"> 
        <a href="javascript:show_calendar('form_.exam_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Time Given</td>
      <td height="30" colspan="4" valign="middle">
       <select name="start_hr">
          <%
		   strTemp = WI.fillTextValue("start_hr");
          if (vEditInfo != null && vEditInfo.size()>0)
	      	strTemp = (String)vEditInfo.elementAt(9);

		     
		iTemp = Integer.parseInt(WI.getStrValue(strTemp,"9"));
		for(i = 1 ; i<=12; ++i) {
		if (iTemp == i){%>
          <option value="<%=i%>" selected>
          <%if(i < 10){%>
          0
          <%}%>
          <%=i%></option>
          <%}else{%>
          <option value="<%=i%>">
          <%if(i < 10){%>
          0
          <%}%>
          <%=i%></option>
          <%}}%>
        </select> <select name="start_min">
          <%
		  strTemp = WI.fillTextValue("start_min");
		  if (vEditInfo != null && vEditInfo.size()>0)
      		strTemp = (String)vEditInfo.elementAt(10);      		    
	  	iTemp = Integer.parseInt(WI.getStrValue(strTemp,"0"));
		for(i = 0 ; i<=55; i += 5) {
		if (iTemp == i){%>
          <option value="<%=i%>" selected>
          <%if(i < 10){%>
          0
          <%}%>
          <%=i%></option>
          <%}else{%>
          <option value="<%=i%>">
          <%if(i < 10){%>
          0
          <%}%>
          <%=i%></option>
          <%}}%>
        </select> <select name="start_ampm">
          <%
          if (vEditInfo != null && vEditInfo.size()>0)
	      	strTemp = (String)vEditInfo.elementAt(11);
	      else
	          strTemp = WI.fillTextValue("start_ampm");
			if(strTemp.compareTo("1") == 0)	{%>
          <option value="0">AM</option>
          <option value="1" selected >PM</option>
          <%}else{%>
          <option value="0" selected>AM</option>
          <option value="1">PM</option>
          <%}%>
        </select>
        (hour,min,AM/PM)
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Duration</td>
      <td height="30" colspan="4" valign="middle">
      <%if (vEditInfo != null && vEditInfo.size()>0)
	      	strTemp = (String)vEditInfo.elementAt(7);
	    else
		     strTemp = WI.fillTextValue("dur_in_min");  %><input name="dur_in_min" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
	   onKeyUp= 'AllowOnlyInteger("form_","dur_in_min")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","dur_in_min");style.backgroundColor="white"' >
        (in mins)
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Venue</td>
      <td height="30" colspan="4" valign="middle">
       <%if (vEditInfo != null && vEditInfo.size()>0)
	      	strTemp = (String)vEditInfo.elementAt(13);
	      else
       strTemp = WI.fillTextValue("venue");%><input type="text" name="venue" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="128" size="64">
      </td>
    </tr>
    <tr> 
      <td height="39">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="39" colspan="4" valign="middle">
      <%if (iAccessLevel>1) {%>
      <font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%></font><%} else {%>&nbsp;<%}%>
      </td>
    </tr>
	<%if (vRetResult!=null && vRetResult.size()>0){%>
    <tr> 
      <td height="25" colspan="6" align="right">
      <font size="1"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a>click to print list</font>
      </td>
    </tr>
    <%}//if result is present
    }// if an sy-term is entered%>
  </table>
  	<%if (vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#C78D8D"> 
      <td  height="25" colspan="9" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF PSYCHOLOGICAL TESTS SCHEDULES FOR : SY <%=WI.fillTextValue("sy_from") + " - "+WI.fillTextValue("sy_to")+
			WI.getStrValue((dbOP.getHETerm(Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"-1"))).toUpperCase()),", ","","")%></strong></font></div></td>
    </tr>
    <tr style="font-weight:bold"> 
      <td width="10%" class="thinborder" align="center" style="font-size:9px">Schedule Code</td>
      <td width="20%" height="28" class="thinborder" align="center" style="font-size:9px">Test Name</td>
      <td width="12%" class="thinborder" align="center" style="font-size:9px">Administered By</td>
      <td width="8%" class="thinborder" align="center" style="font-size:9px">Date Given</td>
      <td width="8%" class="thinborder" align="center" style="font-size:9px">Time</td>
      <td width="7%" class="thinborder" align="center" style="font-size:9px">Duration</td>
      <td width="15%" class="thinborder" align="center" style="font-size:9px">Venue</td>
      <%if(!bolIsUB){%><td width="8%" class="thinborder" align="center" style="font-size:9px">Schedule Student </td><%}%>
      <td width="12%" class="thinborder" align="center" style="font-size:9px">Modify</td>
    </tr>
    <%for (i= 0; i<vRetResult.size(); i+=19){%>
    <tr> 
      <td height="26" class="thinborder"><font size="1"><%=((String)vRetResult.elementAt(i+6))%></font></td>
      <td class="thinborder"><font size="1"><%=((String)vRetResult.elementAt(i+5))%></font></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+15),(String)vRetResult.elementAt(i+16),(String)vRetResult.elementAt(i+17),1)%></font></td>
      <td class="thinborder"><font size="1"><%=((String)vRetResult.elementAt(i+8))%></font></td>
      <td class="thinborder"><font size="1"><%=CommonUtil.formatMinute((String)vRetResult.elementAt(i+9))+':'+
	  CommonUtil.formatMinute((String)vRetResult.elementAt(i+10))+astrConvTime[Integer.parseInt((String)vRetResult.elementAt(i + 11))]%></font></td>
      <td class="thinborder"><font size="1"><%=((String)vRetResult.elementAt(i+7))%> minutes</font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=((String)vRetResult.elementAt(i+13))%></font></td>
      <%if(!bolIsUB){%><td class="thinborder">Added: <%=WI.getStrValue((String)vRetResult.elementAt(i + 18), "0")%> <br>
	  <a href="javascript:AddStudent('<%=vRetResult.elementAt(i)%>');">Add Student</a></td><%}%>
      <td class="thinborder">
      <%if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
		<%}else{%>&nbsp;<%} if (iAccessLevel == 2) {%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>&nbsp;<%}%>      </td>
    </tr>
    <%}%>
    <tr> 
      <td  height="25" colspan="6" class="thinborderBOTTOMLEFT" align="left"><font size="1"><strong>TOTAL 
          PYSCHOLOGICAL TESTS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
      <td colspan="3" align="right" class="thinborderBOTTOM"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
	  int iPageCount = 0;
	  if(PsychTest.defSearchSize !=0){
		iPageCount = iSearchResult/PsychTest.defSearchSize;
		if(iSearchResult % PsychTest.defSearchSize > 0) 
			++iPageCount;
	}
		if(iPageCount > 1){%><select name="jumpto" onChange="ReloadPage();" style="font-size:11px">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%	}
			}// end page printing
			%>
          </select>
          <%} else {%>&nbsp;<%} //if no pages %></td>
    </tr>
    <tr> 
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="9" align="center"><font size="1"><a href="javascript:PrintPage()"> 
        <img src="../../../images/print.gif" border="0"></a>click to print list</font></td>
    </tr>    
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
    <input type="hidden" name="page_action" >
	<input type="hidden" name="print_pg">
</form>
</body>
</html>

