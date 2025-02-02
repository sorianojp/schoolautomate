<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../Ajax/ajax.js" ></script>
<script>
function ViewDetails(strInfoIndex, strStudIndex)
{
	var pgLoc = "./view_dtls_counseling_cases.jsp?stud_id="+strStudIndex+"&info_index="+strInfoIndex+"&counsel_res_index="+strInfoIndex;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
<!--
function StudSearch() {
	var pgLoc = "../../../search/srch_stud.jsp?opner_info=form_.stud_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function CounselSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.counsel_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReferralSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.ref_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID()
{
	document.form_.stud_id.focus();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond){
var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +"&opner_form_name=form_";
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	}


var AjaxCalledPos;
function AjaxMapName(strPos) {
		AjaxCalledPos = strPos;
		var strCompleteName;
		if(strPos == "1")
			strCompleteName = document.form_.stud_id.value;
		else if(strPos == "2")	
			strCompleteName = document.form_.ref_id.value;
		else
			strCompleteName = document.form_.counsel_id.value;
			
		if(strCompleteName.length < 3) {
			this.UpdateNameFormat("");
			return;
		}
		
		var objCOAInput;
		if(strPos == "1")
			objCOAInput = document.getElementById("coa_info1");
		else if(strPos == "2")
			objCOAInput = document.getElementById("coa_info2");
		else
			objCOAInput = document.getElementById("coa_info3");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);
		if(strPos == "2" || strPos == "3")
			strURL += "&is_faculty=1";
		//if(document.form_.account_type[1].checked) //faculty
		//	strURL += "&is_faculty=1";
		//alert(strURL);
		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	if(AjaxCalledPos == "1") {
		document.form_.stud_id.value = strID;
		document.form_.stud_id.focus();
	}
	else if(AjaxCalledPos == "2") {
		document.form_.ref_id.value = strID;
		document.form_.ref_id.focus();
	}
	else {
		document.form_.counsel_id.value = strID;
		document.form_.counsel_id.focus();
	}

}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.form_.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	if(AjaxCalledPos == "1")
		document.getElementById("coa_info1").innerHTML = "";
	else if(AjaxCalledPos == "2")	 
		document.getElementById("coa_info2").innerHTML = "";
	else	 
		document.getElementById("coa_info3").innerHTML = "";
}
-->
</script>
<%@ page language="java" import="utility.*, osaGuidance.GDCounseling, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	Vector vBasicInfo = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrSemester = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};

	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-Counseling Cases-Add/Create","add_counseling_cases.jsp");
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
														"Guidance & Counseling","Counseling Cases",request.getRemoteAddr(),
														"add_counseling_cases.jsp");
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

int iCasesCreatedSYTerm = 0;
int iCasesCreatedTotal  = 0;

//end of authenticaion code.
enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
if(WI.fillTextValue("stud_id").length() > 0 && WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0) {
	vBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));
	//I have to check if enrolled in selected sy-term.. 
	String strSQLQuery = "select cur_hist_index from stud_curriculum_hist where is_valid = 1 and user_index = "+(String)vBasicInfo.elementAt(12)+
						" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester");
	strSQLQuery = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(strSQLQuery == null) {
		strErrMsg = "Student is not enrolled into selected sy-term";
		vBasicInfo = null;
	}
}

if (vBasicInfo !=null && vBasicInfo.size()>0)
{
	GDCounseling GDCounsel = new GDCounseling();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(GDCounsel.operateOnCounselingCase(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = GDCounsel.getErrMsg();
	}
	
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = GDCounsel.operateOnCounselingCase(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = GDCounsel.getErrMsg();
	}

			
	vRetResult = GDCounsel.operateOnCounselingCase(dbOP, request, 4);
	
	if (strErrMsg == null && WI.fillTextValue("stud_id").length()>0)
		strErrMsg = GDCounsel.getErrMsg();
}
else if(strErrMsg == null)
	strErrMsg = OAdm.getErrMsg();
%>
<body bgcolor="#663300" onLoad="FocusID()">
<form action="./add_counseling_cases.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING: COUNSELING RECORD (ANECDOTAL) ENTRY PAGE 
          ::::</strong></font></div></td>
    </tr>
</table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td colspan="4" height="25"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td width="2%"><p>&nbsp;</p></td>
      <td width="17%">School Year</td>
      <td colspan="2"> <% 
        if (vEditInfo != null && vEditInfo.size()>0)
	        strTemp = (String)vEditInfo.elementAt(1);
        else
       		 strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
        <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%  
       if (vEditInfo != null && vEditInfo.size()>0)
	        strTemp = (String)vEditInfo.elementAt(2);
        else
			strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
/
<select name="semester">
  <%
          if (vEditInfo != null && vEditInfo.size()>0)
	        strTemp = (String)vEditInfo.elementAt(3);
        else
			strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0 )
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
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") == 0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}%>
</select></td>

    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Student ID</td>
      <td width="34%" height="25">
     <input name="stud_id" type="text"  value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');"> 
	  
      <!--<a href="javascript:StudSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      <font size="1">click to search for student ID</font>-->
	  <label id="coa_info1" style="position:absolute; width:450px;"></label>
	  
	  </td>
      <td width="47%" height="25"><a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  <%if (vBasicInfo!= null && vBasicInfo.size()>0){
	strTemp =(String)vBasicInfo.elementAt(19);
    %>
    <tr> 
      <td height="25" colspan="4"> <div align="right"> 
          <hr size="1">
        </div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Student Name :<strong><%=WebInterface.formatName((String)vBasicInfo.elementAt(0),
	  (String)vBasicInfo.elementAt(1),(String)vBasicInfo.elementAt(2),4)%></strong></td>
      <td height="25">Gender : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(16),"Not defined")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Brithdate : <strong><%=WI.getStrValue(strTemp, "Undefined")%></strong></td>
      <td height="25">Age :<strong><%if (strTemp !=null && strTemp.length()>0){%><%=CommonUtil.calculateAGEDatePicker(strTemp)%><%}else{%>Undefined<%}%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Course/Major : <strong><%=(String)vBasicInfo.elementAt(7)%> <%=WI.getStrValue((String)vBasicInfo.elementAt(8),"/","","")%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Year Level : <strong><%=WI.getStrValue((String)vBasicInfo.elementAt(14),"N/A")%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Referred by (ID)</td>
      <td height="25" colspan="2">      <% 
          if (vEditInfo != null && vEditInfo.size()>0)
    		strTemp= (String)vEditInfo.elementAt(5);
	      else
    	     strTemp = WI.fillTextValue("ref_id");%>
     <input name="ref_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('2');"> 
	  <!--<a href="javascript:ReferralSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      <font size="1">click to search for employee ID</font>
	  -->
	  <label id="coa_info2" style="position:absolute; width:450px;"></label>
	  </td>
          </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td height="35">Counseled by (ID)</td>
      <td height="35" colspan="2">      <% 
          if (vEditInfo != null && vEditInfo.size()>0)
    		strTemp= (String)vEditInfo.elementAt(9);
	      else
    	     strTemp = WI.fillTextValue("counsel_id");%>
     <input name="counsel_id" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('3');"> 
	  <!--
	  <a href="javascript:CounselSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
      <font size="1">click to search for employee ID</font>
      -->
	  <label id="coa_info3" style="position:absolute; width:450px;"></label>
	  </td>

    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td height="35">Counseing Date</td>
      <td height="35" colspan="2"><%
       if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(13);
		else		
			strTemp = WI.fillTextValue("counsel_date");

		 if (strTemp == null || strTemp.length()==0)
        	  	strTemp = WI.getTodaysDate(1);
		%>
		<input name="counsel_date" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.counsel_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> </td>

    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30">Follow Up</td>
      <td height="30" colspan="2">      <% 
          if (vEditInfo != null && vEditInfo.size()>0)
    		strTemp= (String)vEditInfo.elementAt(14);
	      else
    	     strTemp = WI.fillTextValue("follow_up");%>
     <input name="follow_up" type="text"  value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="64" maxlength="256"> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Type of Problem</td>
      <td height="25" colspan="2"><font size="1">
        <%if (strPrepareToEdit.compareTo("1")==0){%><a href='./problems.jsp?counsel_res_index=<%=((String)vEditInfo.elementAt(0))%>' target="_blank">
	  <img src="../../../images/update.gif" border="0"></a> 
        click to update the problems of this student<%}else{%>edit case
        to access this area<%}%></font></td>
    </tr>
     <tr> 
      <td height="25">&nbsp;</td>
            <td height="25">Reason for Referral : </td>	
      <td height="25" colspan="2" >
       <font size="1">
        <%if (strPrepareToEdit.compareTo("1")==0){%><a href='./reasons.jsp?counsel_res_index=<%=((String)vEditInfo.elementAt(0))%>' target="_blank">
	  <img src="../../../images/update.gif" border="0"></a> 
        click to update reasons for referral of this student<%}else{%>edit case
        to access this area<%}%></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
    </table>
    <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td height="34" width="2%">&nbsp;</td>
      <td width="47%"><strong>OBSERVATIONS AND INTERVIEW FINDINGS:</strong></td>
      <td width="2%">&nbsp;</td>
	  <td width="47%">&nbsp;</td>		
      <td width="2%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="122">&nbsp;</td>
      <td><% 
      if (vEditInfo != null && vEditInfo.size()>0)
    		strTemp= (String)vEditInfo.elementAt(15);
      else
	        strTemp = WI.fillTextValue("background");%>
    Background of the Study :<br> <textarea name="background" cols="35" rows="4" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
      <td>&nbsp;</td>
      <td><% 
      if (vEditInfo != null && vEditInfo.size()>0)
    		strTemp= (String)vEditInfo.elementAt(16);
      else
	        strTemp = WI.fillTextValue("pres_con");%>
    Present Condition :<br> <textarea name="pres_con" cols="35" rows="4" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="122">&nbsp;</td>
      <td><% 
      if (vEditInfo != null && vEditInfo.size()>0)
    		strTemp= (String)vEditInfo.elementAt(17);
      else
	        strTemp = WI.fillTextValue("diff");%>
    Difficulties :<br> <textarea name="diff" cols="35" rows="4" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
	  <td>&nbsp;</td>
      <td height="121"><% 
      if (vEditInfo != null && vEditInfo.size()>0)
    		strTemp= (String)vEditInfo.elementAt(18);
      else
	        strTemp = WI.fillTextValue("conc");%>
    Conclusions & Recommendations; :<br> <textarea name="conc" cols="35" rows="4" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="60" colspan="5" valign="middle"><div align="center"><font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
	<%}
	
	if (vRetResult !=null && vRetResult.size()> 0 && vBasicInfo !=null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#A9C0CD"> 
      <td height="25" colspan="10" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>SUMMARY OF COUNSELING 
          REPORT </strong></font></div></td>
    </tr>
    <tr> 
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>SY/ TERM </strong></font></div></td>
      <td width="13%" height="25" class="thinborder"><div align="center"><font size="1"><strong>COUNSELED 
          BY </strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>REFERRED BY</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>COUNSELING DATE</strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>FOLLOW UP</strong></font></div></td>
      <td width="20%" class="thinborder"><div align="center"><font size="1"><strong>CONCLUSIONS AND RECOMMNEDATIONS </strong></font></div></td>
      <td width="21%" colspan="3" class="thinborder"><div align="center"><strong><font size="1">OPTIONS </font></strong></div></td>
    </tr>
     <%for (int i = 0; i< vRetResult.size(); i+=19){%>
    <tr> 
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%>&nbsp;-&nbsp;<%=(String)vRetResult.elementAt(i+2)%><br><%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+3))]%></font></td>
      <td height="25" class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+10), (String)vRetResult.elementAt(i+11), (String)vRetResult.elementAt(i+12),7)%></font></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+6), (String)vRetResult.elementAt(i+7), (String)vRetResult.elementAt(i+8),7)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+13)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+14)%></font></td>
      <td class="thinborder"><font size="1"><%strTemp = (String)vRetResult.elementAt(i+18);
      if (strTemp.length()>20){%>
      <%=strTemp.substring(0,20)%>...more<%}else{%><%=strTemp%>&nbsp;<%}%></font></td>
      <td width="7%" class="thinborder"><a href='javascript:ViewDetails(<%=((String)vRetResult.elementAt(i))%>, "<%=((String)vRetResult.elementAt(i+4))%>")'>
	  <img src="../../../images/view.gif" width="40" height="31" border="0"></a></td>
      <td width="7%" class="thinborder"><% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
        <%}else{%>&nbsp;<%}%></td>
      <td width="7%" class="thinborder"><% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>&nbsp;<%}%></td>
    </tr>
    <%}%>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
