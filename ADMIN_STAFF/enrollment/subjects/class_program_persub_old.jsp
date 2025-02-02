<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function CheckValidHour() {
	var vTime =document.form_.time_from_hr.value 
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_from_hr.value = "12";
	}
	vTime =document.form_.time_to_hr.value 
	if(eval(vTime) > 12 || eval(vTime) == 0) {
		alert("Time should be >0 and <= 12");
		document.form_.time_to_hr.value = "12";
	}
}
function CheckValidMin() {
	if(eval(document.form_.time_from_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_from_min.value = "00";
	}
	if(eval(document.form_.time_to_min.value) > 59) {
		alert("Time can't be > 59");
		document.form_.time_to_min.value = "00";
	}
}
	function DisplayAll(){
		//if no subject selected, do not load the page.. it is very slow.. 
		//if(document.form_.sub_index.selectedIndex == 0) {
		//	alert("Pls select a subject.");
		//	return;
		//}
		document.form_.showAll.value = "1";
		document.form_.print_page.value = "";
		document.form_.info_index.value= "";
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "";
		document.form_.edit_section_name.value= "";
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value= "1";
		document.form_.submit();
	}
	function PrepareToEdit(strInfoIndex, strSectionName){
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value= strInfoIndex;
		document.form_.edit_section_name.value= strSectionName;

		document.form_.showAll.value = "1";
		document.form_.submit();
	}
	function PageAction(strAction, strInfoIndex){
		if(strInfoIndex.length > 0)
			document.form_.info_index.value= strInfoIndex;
		document.form_.page_action.value = strAction;
		document.form_.showAll.value = "1";
		document.form_.submit();
	}
	function Cancel() {
		this.DisplayAll();
	}
	//Ajax Operation here. 
	function updateOfferingCount (strIndex) {
		var strNewAmount = "";
		var strOldAmount = "";
		var strInfoIndex = "";
	
		eval('strNewAmount=document.form_.offering_count'+strIndex+'.value');
		eval('strOldAmount=document.form_.offering_count_o'+strIndex+'.value');
		eval('strInfoIndex=document.form_.info_index'+strIndex+'.value');
	
		if (strNewAmount == strOldAmount)
			return;
			
		var objAmount;
		eval('objAmount=document.form_.offering_count'+strIndex);

		this.InitXmlHttpObject(objAmount, 1);//I want to get value in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=205&sy_f="+document.form_.sy_from.value+
		"&sem="+document.form_.semester[document.form_.semester.selectedIndex].value+"&new_val="+strNewAmount+
		"&section="+strInfoIndex;
		//alert(strURL);
		this.processRequest(strURL);
	}

function UpdateSectionName(strOrigSection, strInfoIndex) {
	<%if(!strSchCode.startsWith("CIT")){%>
		return;
	<%}%>
	var strNewVal = prompt('Please enter new Section Name.', strOrigSection);
	if(strNewVal == null || strNewVal.length == 0) 
		return;
		
	document.form_.new_sec.value = strNewVal;
	document.form_.sub_sec_i.value = strInfoIndex;
	
	document.form_.showAll.value = "1";
	document.form_.submit();
}

//Ajax Implementation.. 
function ToggleForceCloseOpen(strSubSecRef, strIsDC) {
		var obj = document.getElementById(strSubSecRef);
		if(strIsDC == '1')
			obj = document.getElementById("_22_"+strSubSecRef);
		if(!obj)
			return;

		this.InitXmlHttpObject(obj, 2);//I want to get value in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=124&sub_sec_ref="+strSubSecRef;
		if(strIsDC == '1')
			strURL += "&update_dc=1";
			
		this.processRequest(strURL);
}
function UpdateCapacity(strSubSecRef) {
		var newCapacity = prompt('Please enter new capacity.','');
		if(newCapacity == null || newCapacity.length == 0)
			return;
		
		var obj = document.getElementById("_"+strSubSecRef);
		if(!obj)
			return;

		this.InitXmlHttpObject(obj, 2);//I want to get value in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=125&capacity="+newCapacity+"&sub_sec_ref="+strSubSecRef;
		this.processRequest(strURL);
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="class_program_persub_print.jsp" />
<% }
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Class program per subject","class_program_persub.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"class_program_persub.jsp");
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
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
//I have to update section name here.
if(WI.fillTextValue("new_sec").length() > 0 && WI.fillTextValue("sub_sec_i").length() > 0) {
	String strSQLQuery = "update e_sub_section set section = '"+WI.fillTextValue("new_sec")+"' where sub_sec_index = "+WI.fillTextValue("sub_sec_i");
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
}


Vector vRetResult = null; Vector vAddlInfo = null; int iIndexOf = 0; String strCapacity = null;
enrollment.SubjectSection SS = new enrollment.SubjectSection();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(SS.operateOnCPPerSub(dbOP, request, Integer.parseInt(strTemp)) != null) {
		strErrMsg = "Operation successful.";
		strPrepareToEdit = "";
	}
	else	
		strErrMsg = SS.getErrMsg();
}

if (WI.fillTextValue("showAll").length() >  0) {
	vRetResult = SS.operateOnCPPerSub(dbOP, request,4);
	if (vRetResult == null && strErrMsg == null)
		strErrMsg = " No Record Found";
	else		
		vAddlInfo = (Vector)vRetResult.remove(0);
}


boolean bolIsPhilCST = strSchCode.startsWith("PHILCST");
if(strSchCode.startsWith("EAC"))
	bolIsPhilCST = true;
	
String strSYFrom = (String)request.getParameter("sy_from"); 
String strSem    = (String)request.getParameter("semester");

String[] astrOpenCloseStat = {"&nbsp;","Forced Closed"};

boolean bolAllowAdjustCapacity = false;
strTemp = dbOP.getResultOfAQuery("select prop_val from read_property_file where prop_name = 'ADVISING_CAPACITY'", 0);
if(strTemp != null && strTemp.equals("1"))
	bolAllowAdjustCapacity = true;
else
	bolAllowAdjustCapacity = false;

%>

<form name="form_" action="./class_program_persub.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CLASS PROGRAM - PER SUBJECT - VIEW/EDIT/DELETE/ PRINT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%">&nbsp;</td>
      <td colspan="3" height="25"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td width="35%" valign="bottom">School year : 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");

strSYFrom = strTemp;%> <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strTemp%>" size="4" maxlength="4">
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes"> &nbsp;&nbsp;&nbsp; &nbsp;</td>
      <td width="20%" valign="bottom">Term : 
        <select name="semester" onChange="ReloadPage();">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

strSem = strTemp;

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td width="43%" valign="bottom"><a href="javascript: DisplayAll()"><img src="../../../images/form_proceed.gif"border="0"></a></td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" valign="bottom">Subject Code : <font size="1"> 
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');">
        (enter subject code to scroll the list)</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="3" valign="bottom"><select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code"," from subject where is_del=0 "+
		  		" and exists (select * from e_sub_section where sub_index = subject.sub_index and e_sub_section.is_valid = 1 and "+
				"offering_sy_from = "+strSYFrom+" and offering_sem = "+strSem+") order by s_code",WI.fillTextValue("sub_index"), false)%> </select></td>
    </tr>
    <%
if(strPrepareToEdit.compareTo("1") ==0){%>
     <tr> 
      <td colspan="4" height="19">&nbsp;</td>
    </tr>
   <tr> 
      <td>&nbsp;</td>
      <td height="25" bgcolor="#BBDDFF" class="thinborderTOPLEFTBOTTOM"><strong>New Schedule 
        (M-T-W-TH-F-SAT-S)</strong></td>
      <td bgcolor="#BBDDFF" class="thinborderTOPBOTTOM"><strong>Time From</strong></td>
      <td bgcolor="#BBDDFF" class="thinborderTOPBOTTOMRIGHT"><strong>Time To</strong></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" class="thinborderLEFT">&nbsp;<input type="text" name="week_day" size="20" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("week_day")%>"
	  onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase();"></td>
      <td height="25"><input type="text" name="time_from_hr" size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_hr")%>"
	  onKeyUp="AllowOnlyInteger('form_','time_from_hr');CheckValidHour();">
        : 
        <input type="text" name="time_from_min" size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_from_min")%>"
	  onKeyUp="AllowOnlyInteger('form_','time_from_min');CheckValidMin();">
        : 
        <select name="time_from_AMPM" style="font-size:10px">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_from_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
      <td height="25" class="thinborderRIGHT"><input type="text" name="time_to_hr" size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_hr")%>"
	  onKeyUp="AllowOnlyInteger('form_','time_to_hr');CheckValidHour();">
        : 
        <input type="text" name="time_to_min"  size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("time_to_min")%>"
	  onKeyUp="AllowOnlyInteger('form_','time_to_min');CheckValidMin();">
        : 
        <select name="time_to_AMPM" style="font-size:10px">
          <option selected value="0">AM</option>
          <%
strTemp = WI.fillTextValue("time_to_AMPM");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
    </tr>
<!--
    <tr> 
      <td>&nbsp;</td>
      <td height="25" class="thinborderLEFT">&nbsp;New Section Name (if section 
        name is changed)</td>
      <td colspan="2" class="thinborderRIGHT"><input type="text" name="new_section" size="20" <%=strTemp%> value="<%=WI.fillTextValue("new_section")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeypress="if(event.keyCode==39 || event.keyCode==34) event.returnValue=false;"
	   style="font-size:14px"></td>
    </tr>
-->
    <tr> 
      <td>&nbsp;</td>
      <td height="25" class="thinborderBOTTOMLEFT">&nbsp;<font color="#0055FF"><strong>SECTION TO EDIT : </strong><br>
	  &nbsp;<font size="1"><%=WI.fillTextValue("edit_section_name")%></font></font></td>
      <td height="25" colspan="2" class="thinborderBOTTOMRIGHT"> <font size="1">
	  <%if(iAccessLevel > 1) {%> 
	  	<a href="javascript:PageAction('2','');"><img src="../../../images/edit.gif" border="0"></a> Edit schedule&nbsp;&nbsp;
	  	<a href="javascript:PageAction('1','');"><img src="../../../images/add.gif" border="0"></a> Add a new schedule to existing schedule 
		
        <%}else{%> &nbsp; <%}%> 
		
	  <br>
	  <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
		Cancel edit/add new schedule.</font></td>
    </tr>
    <%}//show only if edit is called.
%>
    <tr> 
      <td colspan="4" height="19">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {
Vector vSubjectUnit = SS.getSubjectUnits(dbOP);
if(vSubjectUnit == null)
	vSubjectUnit = new Vector();//System.out.println(vRetResult);
String strTotalUnits = null;
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="60%" height="25">&nbsp;&nbsp; <strong>Total Schedules Found: 
        <%=vRetResult.size()/11%></strong></td>
      <td width="40%"><div align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click 
          to print list</font></div></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="12" class="thinborder"><div align="center">FINAL SCHEDULE OF CLASSES<strong></strong></div></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold">
<%if(bolIsPhilCST){%>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold" align="center"><font size="1">OFFERING CODE</font></td> 
<%}%>
      <td width="11%" height="25" class="thinborder"><font size="1">SUBJECT CODE</font></td>
      <td width="19%" class="thinborder"><font size="1">DESCRIPTION</font></td>
      <td width="5%" class="thinborder"><font size="1">TOTAL UNITS</font></td>
      <td width="10%" class="thinborder"><font size="1">SECTION</font></div></td>
      <td class="thinborder"><font size="1">SCHEDULE</font></div></td>
      <td width="5%" class="thinborder"><font size="1">ROOM #</font></div></td>
      <td width="5%" class="thinborder"><font size="1"># Enrolled</font></td>
      <td width="5%" class="thinborder"><font size="1">DONOT CHK CONFLICT</font></td>
      <td width="5%" class="thinborder" align="center"><font size="1">Force Close</font></td>
<%if(bolAllowAdjustCapacity){%>
      <td width="5%" class="thinborder"><font size="1">Adjust Capacity</font></td>
<%}%>
      <td width="5%" height="25" class="thinborder"><font size="1">EDIT</font></td>
      <td width="5%" class="thinborder"><font size="1">DELETE</font></td>
    </tr>
    <%
	String strEditRowCol = null; int iCount = 0;
	if(vAddlInfo == null)
		vAddlInfo = new Vector();
		
	for(int i = 0 ; i < vRetResult.size() ; i+=13){ //System.out.println((String)vRetResult.elementAt(i));
	
		iIndexOf = vSubjectUnit.indexOf((String)vRetResult.elementAt(i));
		if(iIndexOf > -1)
			strTotalUnits = (String)vSubjectUnit.elementAt(iIndexOf + 1);
		else	
			strTotalUnits = "&nbsp;";
		
		//System.out.println(vRetResult.elementAt(i + 11));
	 if(strPrepareToEdit.compareTo("1") == 0 && WI.fillTextValue("info_index").compareTo((String)vRetResult.elementAt(i + 4)) == 0)
	 	strEditRowCol = " bgcolor=#99CCFF";
	  else if(((String)vRetResult.elementAt(i + 10)).compareTo("0") != 0)
	  	strEditRowCol = " bgcolor=#FFFFCF";
	  else	
	  	strEditRowCol = "";
	%>
    <tr<%=strEditRowCol%>>
<%if(bolIsPhilCST){
strTemp = SS.convertSubSecIndexToOfferingCount(dbOP, request, (String)vRetResult.elementAt(i+4), strSYFrom, strSem, strSchCode);
%>
      <td class="thinborder">
	  		<input name="offering_count<%=iCount%>" type="text" size="6" class="textbox_noborder2"
			onBlur="updateOfferingCount(<%=iCount%>);style.backgroundColor='white'"
			value="<%=WI.getStrValue(strTemp)%>"
			onfocus="style.backgroundColor='#D3EBFF'">
		<input type="hidden" name="info_index<%=iCount%>" value="<%=(String)vRetResult.elementAt(i + 4)%>">
		<input type="hidden" name="offering_count_o<%=iCount++%>" value="<%=strTemp%>">	  </td> 
<%}%>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td class="thinborder"><%=strTotalUnits%></td>
      <td class="thinborder"><font size="1"><label id="_<%=i%>" onDblClick="UpdateSectionName('<%=(String)vRetResult.elementAt(i+1)%>','<%=(String)vRetResult.elementAt(i+4)%>')"><%=(String)vRetResult.elementAt(i+1)%></label></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 10)%></td>
      <td class="thinborder" align="center" valign="top">&nbsp;<label id="_22_<%=vRetResult.elementAt(i + 4)%>" style="font-weight:bold; font-size:9px; color:#FF0000">
	  <%if( ((String)vRetResult.elementAt(i + 11)).compareTo("1") == 0){%>
	  <img src="../../../images/tick.gif">
	  <%}else{%>
	  <img src="../../../images/x.gif">
	  <%}%></label>
	  <br><br>
	  <!--<a href="javascript:PageAction('5','<%//=(String)vRetResult.elementAt(i + 4)%>');" tabindex="-1">-->
	  <a href="javascript:ToggleForceCloseOpen('<%=vRetResult.elementAt(i + 4)%>','1')" tabindex="-1">
	  <img src="../../../images/update.gif" width="52" height="26" border="1"></a>	  </td>
<%
iIndexOf = vAddlInfo.indexOf(new Integer((String)vRetResult.elementAt(i + 4)));
if(iIndexOf == -1) {
	strCapacity = "&nbsp;";
	strTemp = "&nbsp;";
}
else  {
	strTemp = astrOpenCloseStat[Integer.parseInt((String)vAddlInfo.elementAt(iIndexOf + 2))];
	strCapacity = WI.getStrValue((String)vAddlInfo.elementAt(iIndexOf + 1), "&nbsp;");
}

%>      <td class="thinborder" align="center" onDblClick="ToggleForceCloseOpen('<%=vRetResult.elementAt(i + 4)%>','')"><label id="<%=vRetResult.elementAt(i + 4)%>" style="font-weight:bold; font-size:9px; color:#FF0000"><%=strTemp%></label></td>
<%if(bolAllowAdjustCapacity){%>
      <td class="thinborder" align="center" onDblClick="UpdateCapacity('<%=vRetResult.elementAt(i + 4)%>')"><label id="_<%=vRetResult.elementAt(i + 4)%>"><%=strCapacity%></label></td>
<%}%>
      <td class="thinborder" align="center"> <%if(iAccessLevel > 1 /**&& ((String)vRetResult.elementAt(i + 10)).compareTo("0") == 0**/) {%> <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i + 4)%>,'<%=(String)vRetResult.elementAt(i+1) + ":::"+(String)vRetResult.elementAt(i+5)%>');" tabindex="-1"><img src="../../../images/edit.gif" border="1"></a> 
        <%}else{%>
        &nbsp;
        <%}%></td>
      <td class="thinborder" align="center"> <%if(iAccessLevel == 2 && ((String)vRetResult.elementAt(i + 10)).compareTo("0") == 0) {%> <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i + 4)%>');"><img src="../../../images/delete.gif" border="1" tabindex="-1"></a> 
        <%}else{%>
        &nbsp;
        <%}%> </td>
    </tr>
    <%}//end for loop %>
  </table>
<%} // if (vRetResult != null && vRetResult.size() > 0)%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr > 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" >&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="showAll">
<input type="hidden" name="print_page">

<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="edit_section_name" value="<%=WI.fillTextValue("edit_section_name")%>">

<input type="hidden" name="get_no_conflict" value="1">
<input type="hidden" name="update_dcc"><!--update do not check conflict -->


<input type="hidden" name="new_sec">
<input type="hidden" name="sub_sec_i">

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
