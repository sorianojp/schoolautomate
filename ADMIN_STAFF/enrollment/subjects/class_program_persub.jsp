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
	function ResetPage() {
		document.form_.showAll.value = "";
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
	<%if(!strSchCode.startsWith("CIT") && !strSchCode.startsWith("SWU") && !strSchCode.startsWith("SPC") && !strSchCode.startsWith("DLSHSI")){%>
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
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","CLASS PROGRAM PER SUBJECT",request.getRemoteAddr(),
														null);
}
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
enrollment.SubjectSection SS = new enrollment.SubjectSection();
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
//I have to update section name here.
if(WI.fillTextValue("new_sec").length() > 0 && WI.fillTextValue("sub_sec_i").length() > 0) {
	//get lab sub sec index .. 
	String strSubSecIndex = WI.fillTextValue("sub_sec_i");
	String strLabSubSecIndex = SS.getLabSchIndex(dbOP, strSubSecIndex);
	if(strLabSubSecIndex == null)
		strLabSubSecIndex = SS.getLecSchIndex(dbOP, strSubSecIndex);
	String strSQLQuery = null; 
	
	if(strLabSubSecIndex != null && strLabSubSecIndex.length() > 0)
		strSQLQuery = "update e_sub_section set section = '"+WI.fillTextValue("new_sec")+"' where sub_sec_index in ("+strSubSecIndex+","+strLabSubSecIndex+")";
	else	
		strSQLQuery = "update e_sub_section set section = '"+WI.fillTextValue("new_sec")+"' where sub_sec_index = "+strSubSecIndex;
	//System.out.println(strSQLQuery);
	dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
}


Vector vRetResult = null; Vector vAddlInfo = null; int iIndexOf = 0; String strCapacity = null; Vector vEditSchDtls = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(SS.operateOnCPPerSubNew(dbOP, request, Integer.parseInt(strTemp)) != null) {
		strErrMsg = "Operation successful.";
		strPrepareToEdit = "";
	}
	else	
		strErrMsg = SS.getErrMsg();
}


boolean bolIsEditRestricted = false;
String strRestrictedCon     = "";
//this piece of code put restriction 
if(strSchCode.startsWith("SWU")) {
	bolIsEditRestricted = true;
	boolean bolIsCPSU = new enrollment.SetParameter().bolIsCPSU(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
	boolean bolIsETO  = new enrollment.SetParameter().bolIsETO(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
	
	if(!bolIsCPSU && !bolIsETO) {
		//if not super user.. 
		if(comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),"DUMMY MODULE","DUMMY SUB MODULE",request.getRemoteAddr(),null) > 0) 
			bolIsEditRestricted = false;
	}
	else	
		bolIsEditRestricted = false;
}

if(bolIsEditRestricted) {
	strTemp = "select c_index from info_faculty_basic where is_valid = 1 and user_index = "+
				(String)request.getSession(false).getAttribute("userIndex");
	strTemp = dbOP.getResultOfAQuery(strTemp, 0);
	if(strTemp == null) {
		strErrMsg = "Not allowed to edit class program.";
		strRestrictedCon = " and offered_by_college = -1";
		//added to limit display subject if all is selected.. change applied in ReportFaculty.getFinalSched(...)
		request.setAttribute("per_sub_sch_restricted","-1");
	}
	else {
		strRestrictedCon = " and offered_by_college = "+strTemp;
		request.setAttribute("per_sub_sch_restricted",strTemp);
	}
}
else	
	strRestrictedCon = "";






if (WI.fillTextValue("showAll").length() >  0) {
	vRetResult = SS.operateOnCPPerSub(dbOP, request,4);
	if (vRetResult == null) {
		strErrMsg = SS.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = " No Record Found";
	}
	else		
		vAddlInfo = (Vector)vRetResult.remove(0);
}


boolean bolIsPhilCST = strSchCode.startsWith("PHILCST");
boolean bolIsHTC = strSchCode.startsWith("HTC");
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

boolean bolIsRestrictedPerCollege = false;//if per college is applied.
boolean bolIsReadOnly   = false;
String strLoggedUserCollege = WI.getStrValue((String)request.getSession(false).getAttribute("info_faculty_basic.c_index"), "0");
if(strSchCode.startsWith("NEU")) {
	//check if super user.
	String strAuthID = (String)request.getSession(false).getAttribute("userIndex");
	
	String strSQLQuery = "select auth_list_index from user_auth_list where user_index = "+strAuthID+" and is_Valid = 1 and main_mod_index = 0 and sub_mod_index = 0";
	if(dbOP.getResultOfAQuery(strSQLQuery, 0) == null) {
		boolean bolIsCPSU = new enrollment.SetParameter().bolIsCPSU(dbOP, strAuthID);
		boolean bolIsETO  = new enrollment.SetParameter().bolIsETO(dbOP, strAuthID);
		if(!bolIsCPSU && !bolIsETO)
			bolIsRestrictedPerCollege = true;
	}
	bolIsRestrictedPerCollege = true;
	
	if(bolIsRestrictedPerCollege && !strLoggedUserCollege.equals("0")) {
		strSQLQuery = "select college.c_code from college where c_index= "+strLoggedUserCollege;
		strLoggedUserCollege = dbOP.getResultOfAQuery(strSQLQuery,0);
		if(strLoggedUserCollege == null)
			strLoggedUserCollege= "";
	}
}
//System.out.println(strLoggedUserCollege);

String strRoomOwnerShipFilterCon = "";
if(vRetResult != null && WI.fillTextValue("info_index").length() > 0) {
	if(new utility.ReadPropertyFile().readProperty(dbOP, "ROOM_OWNERSHIP","0").equals("1")) {
		strTemp = dbOP.getResultOfAQuery("select offered_by_college from e_sub_section where sub_sec_index = "+WI.fillTextValue("info_index"), 0);
		//System.out.println("strTemp : "+WI.fillTextValue("info_index"));
		if(strTemp != null) //this query is not complete, as i have to add OR condition if there is already a room, so that it will be shown in the list.. .. 
			strRoomOwnerShipFilterCon = " and ( exists (select * from E_ROOM_ASSIGN_OWNERSHIP where college_index = "+strTemp+" and room_index = e_room_detail.room_index) ";
	}
}

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
      <td colspan="4" height="25"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
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
%> 
        <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes"> &nbsp;&nbsp;&nbsp; &nbsp;</td>
      <td width="20%" valign="bottom">Term : 
        <select name="semester" onChange="ResetPage();">
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
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select> </td>
      <td width="43%" valign="bottom"><a href="javascript: DisplayAll()"><img src="../../../images/form_proceed.gif"border="0"></a></td>
      <td width="15%" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="5"><hr size="1"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">Section Offered: 
	  
	  <select name="section_" style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">
          <option value=""></option>
          <%=dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section"," from e_sub_section where is_valid = 1 and offering_sy_from = "+
		  					strSYFrom+" and offering_sem = "+strSem+strRestrictedCon+" order by e_sub_section.section",WI.fillTextValue("section_"), false)%> </select>	  </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">Subject Code : <font size="1"> 
        <input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');">
        (enter subject code to scroll the list)</font></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td colspan="4" valign="bottom">
	  <select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code"," from subject where is_del=0 "+
		  		" and exists (select * from e_sub_section where sub_index = subject.sub_index and e_sub_section.is_valid = 1 and "+
				"offering_sy_from = "+strSYFrom+" and offering_sem = "+strSem+strRestrictedCon+") order by s_code",WI.fillTextValue("sub_index"), false)%> </select></td>
    </tr>
    <%
if(strPrepareToEdit.compareTo("1") ==0){
vEditSchDtls = SS.getSchedulePerSubject(dbOP, WI.fillTextValue("info_index"));
if(vEditSchDtls == null) 
	vEditSchDtls = new Vector();
int iCount = 0;
      String strRoomIndex = null;
      String strWeekDay   = null;
      
      String strHrFr      = null;
      String strMinFr     = null;
      String strAMPMFr    = null;
      
      String strHrTo      = null;
      String strMinTo     = null;
      String strAMPMTo    = null;
%>
     <tr> 
      <td colspan="5" height="19">&nbsp;</td>
    </tr>
   <tr> 
      <td>&nbsp;</td>
      <td height="25" bgcolor="#BBDDFF" class="thinborderTOPLEFTBOTTOM"><strong>New Schedule (M-T-W-TH-F-SAT-S)</strong></td>
      <td bgcolor="#BBDDFF" class="thinborderTOPBOTTOM"><strong>Time From</strong></td>
      <td bgcolor="#BBDDFF" class="thinborderTOPBOTTOM"><strong>Time To</strong></td>
      <td bgcolor="#BBDDFF" class="thinborderTOPBOTTOMRIGHT"><strong>Room Number</strong> </td>
   </tr>
<%for(int i = 0; i < vEditSchDtls.size(); i += 8, ++iCount) {
      strRoomIndex = (String)vEditSchDtls.elementAt(i + 7);//System.out.println("Printing at start: "+strRoomIndex);
      strWeekDay   = (String)vEditSchDtls.elementAt(i + 0);
      
      strHrFr      = (String)vEditSchDtls.elementAt(i + 1);
      strMinFr     = (String)vEditSchDtls.elementAt(i + 2);
      strAMPMFr    = (String)vEditSchDtls.elementAt(i + 3);
      
      strHrTo      = (String)vEditSchDtls.elementAt(i + 4);
      strMinTo     = (String)vEditSchDtls.elementAt(i + 5);
      strAMPMTo    = (String)vEditSchDtls.elementAt(i + 6);

if(WI.fillTextValue("week_day"+iCount).length() > 0)
	strTemp = WI.fillTextValue("week_day"+iCount);
else	
	strTemp = strWeekDay;
%>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" class="thinborderLEFT">&nbsp;<input type="text" name="week_day<%=iCount%>" size="20" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase();"></td>
<%
if(WI.fillTextValue("time_from_hr"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_from_hr"+iCount);
else	
	strTemp = strHrFr;
%>
      <td height="25"><input type="text" name="time_from_hr<%=iCount%>" size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeyUp="AllowOnlyInteger('form_','time_from_hr<%=iCount%>');CheckValidHour();">
        : 
<%
if(WI.fillTextValue("time_from_min"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_from_min"+iCount);
else	
	strTemp = strMinFr;
%>
        <input type="text" name="time_from_min<%=iCount%>" size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeyUp="AllowOnlyInteger('form_','time_from_min<%=iCount%>');CheckValidMin();">
        : 
<%
if(WI.fillTextValue("time_from_AMPM"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_from_AMPM"+iCount);
else	
	strTemp = strAMPMFr;
%>
        <select name="time_from_AMPM<%=iCount%>" style="font-size:10px">
          <option selected value="0">AM</option>
<%
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
 <%
if(WI.fillTextValue("time_to_hr"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_to_hr"+iCount);
else	
	strTemp = strHrTo;
%>
     <td height="25"><input type="text" name="time_to_hr<%=iCount%>" size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeyUp="AllowOnlyInteger('form_','time_to_hr<%=iCount%>');CheckValidHour();">
        : 
<%
if(WI.fillTextValue("time_to_min"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_to_min"+iCount);
else	
	strTemp = strMinTo;
%>
        <input type="text" name="time_to_min<%=iCount%>"  size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeyUp="AllowOnlyInteger('form_','time_to_min<%=iCount%>');CheckValidMin();">
        : 
<%
if(WI.fillTextValue("time_to_AMPM"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_to_AMPM"+iCount);
else	
	strTemp = strAMPMTo;
%>
        <select name="time_to_AMPM<%=iCount%>" style="font-size:10px">
          <option selected value="0">AM</option>
<%
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
      <td class="thinborderRIGHT">
<%
if(WI.fillTextValue("room_index"+iCount).length() > 0)
	strTemp = WI.fillTextValue("room_index"+iCount);
else	
	strTemp = strRoomIndex;

strErrMsg = "";
if(strRoomOwnerShipFilterCon.length() > 0) {
	if(strTemp != null && strTemp.length() > 0) 
		strErrMsg = strRoomOwnerShipFilterCon + " or e_room_detail.room_index = "+strTemp+") ";
	else	
		strErrMsg = strRoomOwnerShipFilterCon+" ) ";
}
//System.out.println(strErrMsg);	
%>
	  <select name="room_index<%=iCount%>" style="font-size:12px; color:#0000FF; font-weight:bold">
          <%=dbOP.loadCombo("room_index","room_number"," from e_room_detail where is_valid = 1 "+strErrMsg+" order by room_number", strTemp, false)%>
        </select>	  </td>
    </tr>
<%}//end of loop%>

<%
//add one more... 
++iCount;

if(WI.fillTextValue("week_day"+iCount).length() > 0)
	strTemp = WI.fillTextValue("week_day"+iCount);
else	
	strTemp = "";
%>
    <tr> 
      <td>&nbsp;</td>
      <td height="25" class="thinborderLEFT">&nbsp;<input type="text" name="week_day<%=iCount%>" size="20" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeypress=" if(event.keyCode>47 && event.keyCode < 58) event.returnValue=false;" OnKeyUP="javascript:this.value=this.value.toUpperCase();"></td>
<%
if(WI.fillTextValue("time_from_hr"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_from_hr"+iCount);
else	
	strTemp = "";
%>
      <td height="25"><input type="text" name="time_from_hr<%=iCount%>" size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeyUp="AllowOnlyInteger('form_','time_from_hr<%=iCount%>');CheckValidHour();">
        : 
<%
if(WI.fillTextValue("time_from_min"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_from_min"+iCount);
else	
	strTemp = "";
%>
        <input type="text" name="time_from_min<%=iCount%>" size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeyUp="AllowOnlyInteger('form_','time_from_min<%=iCount%>');CheckValidMin();">
        : 
<%
if(WI.fillTextValue("time_from_AMPM"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_from_AMPM"+iCount);
else	
	strTemp = "";
%>
        <select name="time_from_AMPM<%=iCount%>" style="font-size:10px">
          <option selected value="0">AM</option>
<%
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
 <%
if(WI.fillTextValue("time_to_hr"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_to_hr"+iCount);
else	
	strTemp = "";
%>
     <td height="25"><input type="text" name="time_to_hr<%=iCount%>" size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeyUp="AllowOnlyInteger('form_','time_to_hr<%=iCount%>');CheckValidHour();">
        : 
<%
if(WI.fillTextValue("time_to_min"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_to_min"+iCount);
else	
	strTemp = "";
%>
        <input type="text" name="time_to_min<%=iCount%>"  size="2" maxlength="2" class="textbox" style="font-size:14px"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"
	  onKeyUp="AllowOnlyInteger('form_','time_to_min<%=iCount%>');CheckValidMin();">
        : 
<%
if(WI.fillTextValue("time_to_AMPM"+iCount).length() > 0)
	strTemp = WI.fillTextValue("time_to_AMPM"+iCount);
else	
	strTemp = "";
%>
        <select name="time_to_AMPM<%=iCount%>" style="font-size:10px">
          <option selected value="0">AM</option>
<%
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
      <td class="thinborderRIGHT">
<%
if(WI.fillTextValue("room_index"+iCount).length() > 0)
	strTemp = WI.fillTextValue("room_index"+iCount);
else	
	strTemp = "";

strErrMsg = "";
if(strRoomOwnerShipFilterCon.length() > 0) {
	if(strTemp != null && strTemp.length() > 0) 
		strErrMsg = strRoomOwnerShipFilterCon + " or e_room_detail.room_index = "+strTemp+" )";
	else	
		strErrMsg = strRoomOwnerShipFilterCon+" ) ";
}
//System.out.println(strErrMsg);	
%>
	  <select name="room_index<%=iCount%>" style="font-size:12px; color:#0000FF; font-weight:bold">
          <%=dbOP.loadCombo("room_index","room_number"," from e_room_detail where is_valid = 1 "+strErrMsg+" order by room_number", strTemp, false)%>
        </select>	  </td>
    </tr>

<input type="hidden" name="max_disp" value="<%=iCount%>">




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
      <td height="25" colspan="3" class="thinborderBOTTOMRIGHT"> <font size="1">
	  <%if(iAccessLevel > 1) {%> 
	  	<a href="javascript:PageAction('2','');"><img src="../../../images/update.gif" border="0"></a> Update Schedule&nbsp;&nbsp;		
        <%}else{%> &nbsp; <%}%> 
		
	  <br>
	  <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
		Cancel edit/add new schedule.</font></td>
    </tr>
    <%}//show only if edit is called.
%>
    <tr> 
      <td colspan="5" height="19">&nbsp;</td>
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
<%if(bolIsPhilCST || bolIsHTC){%>
      <td width="5%" class="thinborder" style="font-size:9px; font-weight:bold" align="center"><font size="1">
	  <%if(bolIsHTC) {%>
	  TERM
	  <%}else{%>
	  OFFERING CODE
	  <%}%>
	  </font></td> 
<%}%>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold" align="center">OFFERED BY COLLEGE-DEPT </td>
      <td width="10%" height="25" class="thinborder"><font size="1">SUBJECT CODE</font></td>
      <td width="18%" class="thinborder"><font size="1">DESCRIPTION</font></td>
      <td width="4%" class="thinborder"><font size="1">TOTAL UNITS</font></td>
      <td width="10%" class="thinborder"><font size="1">SECTION</font></div></td>
      <td class="thinborder"><font size="1">SCHEDULE</font></div></td>
      <td width="5%" class="thinborder"><font size="1">ROOM #</font></div></td>
      <td width="4%" class="thinborder"><font size="1"># Enrolled</font></td>
      <td width="4%" class="thinborder"><font size="1">DONOT CHK CONFLICT</font></td>
      <td width="4%" class="thinborder" align="center"><font size="1">Force Close</font></td>
<%if(bolAllowAdjustCapacity){%>
      <td width="4%" class="thinborder"><font size="1">Adjust Capacity</font></td>
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

	//I have to check if allowed to edit.. only if it is restricted.. 
	bolIsReadOnly = false;
	if(bolIsRestrictedPerCollege) {
		strTemp = WI.getStrValue(vRetResult.elementAt(i + 12), "&nbsp;");
		if(strTemp.indexOf("-") > 0) {
			if(!strTemp.startsWith(strLoggedUserCollege+"-"))
				bolIsReadOnly = true;
		}
		else if(!strTemp.equals(strLoggedUserCollege))
			bolIsReadOnly = true;
	}
	if(bolIsReadOnly)
		strEditRowCol = " bgcolor=#cccccc";
		

	%>
    <tr<%=strEditRowCol%>>
<%if(bolIsPhilCST || bolIsHTC){
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
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 12), "&nbsp;")%></td>
      <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
      <td class="thinborder"><%=strTotalUnits%></td>
      <td class="thinborder"><font size="1"><label id="_<%=i%>" onDblClick="UpdateSectionName('<%=(String)vRetResult.elementAt(i+1)%>','<%=(String)vRetResult.elementAt(i+4)%>')"><%=(String)vRetResult.elementAt(i+1)%></label></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+5)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+7)%></font></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 10)%></td>
      <td class="thinborder" align="center" valign="center">&nbsp;<label id="_22_<%=vRetResult.elementAt(i + 4)%>" style="font-weight:bold; font-size:9px; color:#FF0000">
	  <%if( ((String)vRetResult.elementAt(i + 11)).compareTo("1") == 0){%>
	  <img src="../../../images/tick.gif">
	  <%}else{%>
	  <img src="../../../images/x.gif">
	  <%}%></label>
	  <br><br>
	  <!--<a href="javascript:PageAction('5','<%//=(String)vRetResult.elementAt(i + 4)%>');" tabindex="-1">-->
	  <%if(!bolIsReadOnly) {%>
	  <a href="javascript:ToggleForceCloseOpen('<%=vRetResult.elementAt(i + 4)%>','1')" tabindex="-1">
	  <img src="../../../images/update.gif" width="52" height="26" border="1"></a>	  
	  <%}%>
	  </td>
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

%>      <td class="thinborder" align="center" <%if(iAccessLevel > 1 && !bolIsReadOnly){%>onDblClick="ToggleForceCloseOpen('<%=vRetResult.elementAt(i + 4)%>','')"<%}%>><label id="<%=vRetResult.elementAt(i + 4)%>" style="font-weight:bold; font-size:9px; color:#FF0000"><%=strTemp%></label></td>
<%if(bolAllowAdjustCapacity){%>
      <td class="thinborder" align="center" <%if(iAccessLevel > 1 && !bolIsReadOnly){%>onDblClick="UpdateCapacity('<%=vRetResult.elementAt(i + 4)%>')"<%}%>><label id="_<%=vRetResult.elementAt(i + 4)%>"><%=strCapacity%></label></td>
<%}%>
      <td class="thinborder" align="center"> <%if(iAccessLevel ==2 && !bolIsReadOnly /**&& ((String)vRetResult.elementAt(i + 10)).compareTo("0") == 0**/) {%> <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i + 4)%>,'<%=(String)vRetResult.elementAt(i+1) + ":::"+(String)vRetResult.elementAt(i+5)%>');" tabindex="-1"><img src="../../../images/edit.gif" border="1"></a> 
        <%}else{%>
        &nbsp;
        <%}%></td>
      <td class="thinborder" align="center"> <%if(iAccessLevel == 2 && !bolIsReadOnly && ((String)vRetResult.elementAt(i + 10)).compareTo("0") == 0) {%> <a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i + 4)%>');"><img src="../../../images/delete.gif" border="1" tabindex="-1"></a> 
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

<%if(bolIsEditRestricted){%>
	<input type="hidden" name="is_restricted" value="1">
<%}%>
	

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
