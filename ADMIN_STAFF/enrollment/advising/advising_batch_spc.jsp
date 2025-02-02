<%if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-weight:bold; font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif">You are already logged out. Please login again.</p>
<%return;}
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("auth_type_index");
if(strAuthTypeIndex == null)
	strAuthTypeIndex = "0";
%>
<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
	String strStudID = WI.fillTextValue("stud_id");
	
	
	String strSYFrom = WI.fillTextValue("sy_from");
	String strSYTo   = WI.fillTextValue("sy_to");
	String strTerm   = WI.fillTextValue("semester");
	if(strSYFrom.length() == 0) {
		strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
		strSYTo   = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
		strTerm   = (String)request.getSession(false).getAttribute("cur_sem");
	}
	
	String strSchCode       = (String)request.getSession(false).getAttribute("school_code");

	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
															"advising_batch_spc.jsp");
	
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



boolean bolIsParamSet = false;
String strCourseCode  = null;
String strMajorCode   = null;
String strYearLevel   = null;
String[] astrConvertTerm = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};
String strSQLQuery    = null;
java.sql.ResultSet rs = null;
Vector vCurYr = new Vector();

Advising advising = new Advising();
Vector vBlockSection = null;

boolean bolDonotRemoveErrMsg = false;
if(WI.fillTextValue("remove_advising").length() > 0) {
	if(!advising.removeStudentAdvisedInBlockSectionSPC(dbOP, request))
		strErrMsg = advising.getErrMsg();
	else	
		strErrMsg = "Advising removed successfully.";
	bolDonotRemoveErrMsg = true;
}
else if(WI.fillTextValue("add_stud").length() > 0) {
	strErrMsg = null;
	String strStudIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
	//must check if blocked from advising.. 
	enrollment.FAFeeOperation fOperation = new enrollment.FAFeeOperation();
	fOperation.isEnrolling(true);
	double dOutstanding= fOperation.calOutStandingOfPrevYearSem(dbOP, strStudIndex, true, true);

//System.out.println(dOutstanding);
	enrollment.SetParameter sParam = new enrollment.SetParameter();
	if(!sParam.allowAdvising(dbOP, strStudIndex, dOutstanding, strSYFrom, strTerm))
		strErrMsg = sParam.getErrMsg();	
	else if(sParam.isStudLockedByDept(dbOP, strStudIndex, strSYFrom, strTerm))
		strErrMsg = sParam.getErrMsg();	
	if(strErrMsg == null) {
		if(!advising.saveStudentAdviseInBlockSectionSPC(dbOP, request))
			strErrMsg = advising.getErrMsg();
		else	
			strErrMsg = "Advising successful. Subjects added successfully.";
	}
	bolDonotRemoveErrMsg = true;
}


if(WI.fillTextValue("sy_from").length() > 0) {
	bolIsParamSet = true;
	strSQLQuery = "select course_code from course_offered where course_index = "+WI.fillTextValue("course_index");	
	strCourseCode = dbOP.getResultOfAQuery(strSQLQuery, 0);
	if(WI.fillTextValue("major_index").length() > 0) {
		strSQLQuery  = "select course_code from major where major_index = "+WI.fillTextValue("major_index");	
		strMajorCode = dbOP.getResultOfAQuery(strSQLQuery, 0);
	}
	
	vBlockSection = advising.getBlockSecListBatchAdvisingSPC(dbOP, request);
	if(vBlockSection == null && !bolDonotRemoveErrMsg)
		strErrMsg = advising.getErrMsg();
}
else if(WI.fillTextValue("course_i").length() > 0) {
	strSQLQuery = "select distinct sy_from, sy_to from curriculum where is_valid = 1 and  course_index = "+
		WI.fillTextValue("course_i")+WI.getStrValue(WI.fillTextValue("major_i"), " and major_index = ", "","")+
		" order by sy_from desc"; //System.out.println(strSQLQuery);
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		vCurYr.addElement(rs.getString(1));
		vCurYr.addElement(rs.getString(2));
	}
	rs.close();
}
	
Vector vBlockSecSchDetail = null;
if(WI.fillTextValue("section_").length() > 0) {
	String strCYFRTO   = WI.fillTextValue("cy_fr");
    String strCYFrom = strCYFRTO.substring(0, strCYFRTO.indexOf("-"));
    String strCYTo   = strCYFRTO.substring(strCYFRTO.indexOf("-") + 1);
	
	//System.out.println(strCYFrom);
	//System.out.println(strCYTo);

	enrollment.SubjectSection SS = new enrollment.SubjectSection();
	vBlockSecSchDetail = SS.getSchOfASecForACourse(dbOP,WI.fillTextValue("section_"),WI.fillTextValue("course_index"),
		WI.fillTextValue("major_index"),	strCYFrom, strCYTo,
		WI.fillTextValue("y_l"), WI.fillTextValue("semester"), WI.fillTextValue("sy_from"),
		WI.fillTextValue("sy_to"), WI.fillTextValue("semester"), strSchCode);

	if(vBlockSecSchDetail == null && !bolDonotRemoveErrMsg)
		strErrMsg = SS.getErrMsg();
	//System.out.println(vBlockSecSchDetail);
}	
Vector vStudAdvisedList	= null;
if(WI.fillTextValue("section_").length() > 0) {
	vStudAdvisedList = advising.getStudentAdvisedInBlockSectionSPC(dbOP, request);
	if(vStudAdvisedList == null && !bolDonotRemoveErrMsg)
		strErrMsg = advising.getErrMsg();
	//System.out.println(vBlockSecSchDetail);
}	
	
boolean bolAllowAdvising = true;
int iSeatsAvailable = 0;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Batch Advising</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>
</head>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(strResetSection) {
	document.form_.add_stud.value = '';
	document.form_.remove_advising.value = '';
	
	if(strResetSection && document.form_.section_) {
		document.form_.section_.selectedIndex=0;
	}
	document.form_.submit();
}

function ReSetInfo() {
	if(!confirm('Are you sure you want to start over advising.'))
		return;
		
	location = "./advising_batch_spc.jsp";
}
function SetInfo() {

	if(document.form_.y_l.selectedIndex == 0) {
		alert("Please select year level");
		return ;
	}
	if(document.form_.cy_f.selectedIndex == -1) {
		alert("Please select curriculum year");
		return ;
	}

	document.form_.sy_from.value = document.form_.syf.value;
	document.form_.sy_to.value = document.form_.syt.value;
	document.form_.semester.value = document.form_.sem[document.form_.sem.selectedIndex].value;
	document.form_.course_index.value = document.form_.course_i[document.form_.course_i.selectedIndex].value;
	if(document.form_.major_i.selectedIndex > -1)
		document.form_.major_index.value = document.form_.major_i[document.form_.major_i.selectedIndex].value;
	document.form_.year_level.value = document.form_.y_l[document.form_.y_l.selectedIndex].value;
	document.form_.cy_fr.value = document.form_.cy_f[document.form_.cy_f.selectedIndex].value;
	
	ReloadPage();
}
function ShowHideBlockSectionView(strOnLoad) {
	var obj = document.getElementById('show_hide');
	var objC = document.getElementById('bs_info');
	var strInnerContent = obj.innerHTML;
	
	if(!obj || !objC)
		return;
	//alert(strInnerContent+document.form_.show_hide_stat.value);
	//if plage is reloaded but view is closed, i have to force close it.. 
	if(strOnLoad == '1') {
		if(strInnerContent == 'Click to Close View' && document.form_.show_hide_stat.value == '1') {
			strInnerContent = 'Click to Show Detail';
		}
	}
	//alert(strInnerContent);
	if(strInnerContent == 'Click to Close View') {
		objC.style.visibility='hidden';	
		obj.innerHTML = "Click to Show Detail";
		document.form_.show_hide_stat.value = "0";
	}
	else {	
		objC.style.visibility='visible';
		obj.innerHTML = "Click to Close View";
		document.form_.show_hide_stat.value = "1";
	}
}
function ShowHideBlockStudentView() {
	var obj = document.getElementById('show_hide2');
	var objC = document.getElementById('bs_info2');
	var strInnerContent = obj.innerHTML;
	
	if(!obj || !objC)
		return;
	if(strInnerContent == 'Click to Close View') {
		objC.style.visibility='hidden';	
		obj.innerHTML = "Click to Show Detail";
	}
	else {	
		objC.style.visibility='visible';
		obj.innerHTML = "Click to Close View";
	}
}
function SelALL() {
	var bolIsChecked = document.form_.sel_all.checked;
	var iCount = document.form_.max_disp.value;
	
	var obj;
	for(i = 0; i < iCount; ++i) {
		eval('obj=document.form_.useri_'+i);
		if(!obj)
			continue;
		obj.checked = bolIsChecked;
	}
}
function RemoveAdvising() {
	document.form_.add_stud.value = '';

	if(!confirm('This operation will only remove the subjects advised under the selcted section. Click Ok to Proceed.'))
		return;
	document.form_.remove_advising.value = '1';
	document.form_.submit();
}
function AddStudent() {
	document.form_.remove_advising.value = '';

	document.form_.add_stud.value = '1';
	document.form_.submit();
}
function loadMajor() {
		var objCOA=document.getElementById("load_major");
		
		var objCourseInput = document.form_.course_i[document.form_.course_i.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=104&sel_name=major_i&course_ref="+objCourseInput;
		this.processRequest(strURL);
}

function AjaxMapName(strRef) {
		var strSearchCon = "";
		
		var strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length  < 3) 
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
		//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	document.form_.stud_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function CallOnLoad(strStat) {
	if(strStat == '1') {
		document.all.processing.style.visibility='visible';
		document.bgColor = "#CCCCCC";
	}
	else
		document.all.processing.style.visibility='hidden';
}

</script>

<body bgcolor="#D2AE72" onLoad="CallOnLoad('');ShowHideBlockSectionView('1')">
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
	<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
		  <tr>
				<td align="center" class="v10blancong" bgcolor="#FFCC66">
				<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
				<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>
	
				<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
		  </tr>
	</table>
</div>
<form name="form_" action="./advising_batch_spc.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" bgcolor="#A49A6A" align="center"><strong> <font color="#FFFFFF">
        :::: BATCH ADVISING PAGE :::: </font></strong></td>
    </tr>
<%if(strErrMsg != null) {%>
    <tr>
      <td height="25" colspan="8" style="font-weight:bold; font-size:24px; color:#FF0000">&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
<%}%>
  </table>
<%if(!bolIsParamSet) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="24">&nbsp;</td>
		  <td height="35" colspan="4" style="font-size:20px; font-weight:bold" valign="top"><u>-- Set all Parameters --</u></td>
		</tr>
		<tr> 
		  <td width="2%" height="24">&nbsp;</td>
		  <td width="9%" style="font-size:14px;">SY-Term </td>
		  <td width="89%" height="24" colspan="3"> 
		  <input name="syf" type="text" size="4" maxlength="4" value="<%=strSYFrom%>" class="textbox" style="font-size:14px;"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		  onKeyUp='DisplaySYTo("form_","syf","syt")'>
			- 
			<input name="syt" type="text" size="4" maxlength="4" value="<%=strSYTo%>" class="textbox" style="font-size:14px;"
		  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; <select name="sem" style="font-size:14px;">
			<%=CommonUtil.constructTermList(dbOP, request, strTerm)%>
			</select>      </td>
		</tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td style="font-size:14px;">Course</td>
		  <td height="24" colspan="3">
			<select name="course_i" onChange="ReloadPage();" style="font-size:14px; width:500px;"><!-- instead of loadMajor -->
			  <option value=""></option>
				<%=dbOP.loadCombo("course_index","course_code,course_name"," from course_offered where IS_DEL=0 AND is_valid = 1 and degree_type = 0 and is_offered = 1 and exists (select course_index from curriculum where is_valid = 1 and course_index = course_offered.course_index) order by course_name asc",	WI.fillTextValue("course_i"), false)%> 
			</select>	  </td>
		</tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td style="font-size:14px;">Major</td>
		  <td height="24" colspan="3">
	<label id="load_major">
			<select name="major_i" style="font-size:14px;">
	<%if(WI.fillTextValue("course_i").length() > 0) {%>
				<%=dbOP.loadCombo("major_index","major_name"," from	 major where IS_DEL=0 and course_index = " + WI.fillTextValue("course_i") + " order by major_name asc",	WI.fillTextValue("major_i"), false)%> 
	<%}%>
			</select> 		  
	</label>	  </td>
		</tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td style="font-size:14px;">Year Level </td>
		  <td height="24" colspan="3">
		  <select name="y_l" style="font-size:14px;">
			<option value=""></option>
			<%
			int iDef = Integer.parseInt(WI.getStrValue(WI.fillTextValue("y_l"), "0"));
			for (int i =1 ; i < 7; ++i){
			if(i == iDef)
				strErrMsg = " selected";
			else	
				strErrMsg = "";
			%>
				<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
			<%}%>
			</select>	  </td>
		</tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td style="font-size:14px;">Cur. Yr</td>
		  <td height="24" colspan="3">
			<select name="cy_f">
			<%
			strTemp = WI.fillTextValue("cy_f");
			for(int i = 0; i < vCurYr.size(); i += 2) {
				if(strTemp.equals(vCurYr.elementAt(i)+"-"+vCurYr.elementAt(i+1)))
					strErrMsg = " selected";
				else	
					strErrMsg = "";
			%>
			  	<option value="<%=vCurYr.elementAt(i)+"-"+vCurYr.elementAt(i+1)%>"<%=strErrMsg%>><%=vCurYr.elementAt(i) + "-"+vCurYr.elementAt(i + 1)%></option>
			<%}%>	  
		    </select>
		  </td>
	  </tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td height="24">&nbsp;</td>
		  <td height="24" colspan="3">
			<input type="button" name="12" value=" Set Parameters >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="SetInfo();">		  
		  </td>
		</tr>
  </table>
<%}else{%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="24">&nbsp;</td>
		  <td height="35" colspan="3" style="font-size:20px; font-weight:bold" valign="top"><u>-- BATCH ADVISING SET FOR --</u></td>
		</tr>
		<tr> 
		  <td width="2%" height="24">&nbsp;</td>
		  <td width="14%" style="font-size:14px;">SY-Term </td>
		  <td width="40%" height="24" style="font-size:14px; font-weight:bold"><%=astrConvertTerm[Integer.parseInt(strTerm)]%>, <%=strSYFrom%> - <%=strSYTo%></td>
		  <td width="44%" height="24" style="font-size:14px; font-weight:bold"><font style="font-weight:normal">Curriculum Year:</font> <%=WI.fillTextValue("cy_fr")%></td>
		</tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td style="font-size:14px;">Course</td>
		  <td height="24" colspan="2" style="font-size:14px; font-weight:bold"><%=strCourseCode%><%=WI.getStrValue(strMajorCode, " - ","","")%></td>
		</tr>
		
		<tr>
		  <td height="24">&nbsp;</td>
		  <td style="font-size:14px;">Year Level </td>
		  <td height="24" colspan="2" style="font-size:14px; font-weight:bold"><%=WI.getStrValue(WI.fillTextValue("year_level"), "NA")%></td>
		</tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td height="24">&nbsp;</td>
		  <td height="24" colspan="2">
			<input type="button" name="12" value=" Reset Parameters >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="ReSetInfo();">		  
          </td>
		</tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td style="font-size:14px;">List of Section </td>
		  <td colspan="2">
		  <%if(vBlockSection == null) {%> No Section found
		  <%}else{%>
			<select name="section_" onChange="ReloadPage();">
				<option value=""></option>
				<%
				strTemp = WI.fillTextValue("section_");
				for(int i = 0; i < vBlockSection.size(); i += 2) {
					if(strTemp.equals(vBlockSection.elementAt(i))) {
						iSeatsAvailable = Integer.parseInt((String)vBlockSection.elementAt(i + 1));
						if(iSeatsAvailable < 0)
							iSeatsAvailable = 0;
							
						strErrMsg = " selected";
					}
					else	
						strErrMsg = "";
					%>
					<option value="<%=vBlockSection.elementAt(i)%>"<%=strErrMsg%>><%=vBlockSection.elementAt(i)%> (Available: <%=vBlockSection.elementAt(i + 1)%>)</option>
				<%}%>
			</select>	
		  <%}%>		  
			<%
			strTemp = WI.fillTextValue("show_con");
			if(strTemp.length() == 0) 
				strTemp = "1";
			
			if(strTemp.equals("1"))
				strErrMsg = " checked";
			else	
				strErrMsg  = " onClick='ReloadPage(1);'";
			%>
							
			&nbsp;&nbsp;
			<font style="font-size:9px;">
				<input type="radio" name="show_con" value="1"<%=strErrMsg%>> Show Available &nbsp;&nbsp;
			<%
			if(strTemp.equals("2"))
				strErrMsg = " checked";
			else	
				strErrMsg  = " onClick='ReloadPage();'";
			%>
				<input type="radio" name="show_con" value="2"<%=strErrMsg%>> Show All &nbsp;&nbsp;
			<%
			if(strTemp.equals("0"))
				strErrMsg = " checked";
			else	
				strErrMsg  = " onClick='ReloadPage();'";
			%>
				<input type="radio" name="show_con" value="0"<%=strErrMsg%>> Show Closed			</font>		  
		  
		  </td>
	  </tr>
<%if(vBlockSecSchDetail != null) {%>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td height="35" colspan="3" valign="top"><font style="font-size:20px; font-weight:bold"><u>-- BLOCK SECTION DETAIL (Seats Available: <%=iSeatsAvailable%>) --</u></font>
		  
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <label id="show_hide" onClick="ShowHideBlockSectionView('')" style="color:#0000FF; font-weight:bold">Click to Close View</label>
		  
		  <div id="bs_info" style="position:absolute; width:97%; visibility:hidden">
				  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
					<tr bgcolor="#CCCCCC">
					  <td width="11%" height="20" class="thinborder"><div align="center"><strong><font size="1">SUBJECT</font></strong></div></td>
					  <td width="25%" class="thinborder"><div align="center"><font size="1"><strong>SCHEDULE (Days/Time)</strong></font></div></td>
					  <td width="8%" class="thinborder"><div align="center"><strong><font size="1">CAPACITY</font></strong></font></div></td>
					  <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>STUDENTS ENROLLED</strong></font></div></td>
					  <td width="6%" class="thinborder"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
					</tr>
					<%
				for(int i=0; i< vBlockSecSchDetail.size(); i += 8){
				 %>
					<tr>
					  <td height="20" class="thinborder"><%=(String)vBlockSecSchDetail.elementAt(i)%></td>
					<td class="thinborder"> <%=(String)vBlockSecSchDetail.elementAt(i+2)%> </td>
					<td align="center" class="thinborder"><%=(String)vBlockSecSchDetail.elementAt(i+5)%></td>
					<td align="center" class="thinborder"><%=(String)vBlockSecSchDetail.elementAt(i+6)%></td>				
					<td align="center" class="thinborder"><%=(String)vBlockSecSchDetail.elementAt(i+7)%></td>
					</tr>
				 <%}%>
				  </table>
			</div>		  </td>
		</tr>
<%}%>
<%if(vStudAdvisedList != null) {%>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td height="35" colspan="3" valign="top"><font style="font-size:20px; font-weight:bold"><u>-- ADVISED STUDENT DETAIL --</u></font>
		  
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <label id="show_hide2" onClick="ShowHideBlockStudentView('')" style="color:#0000FF; font-weight:bold">Click to Show Detail</label>
		  
		  <div id="bs_info2" style="position:absolute; width:97%; visibility:hidden">
				  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
					<tr bgcolor="#FFFFCC">
					  <td width="5%" class="thinborder" align="center">Count</td>
					  <td width="15%" height="20" class="thinborder"><div align="center"><strong><font size="1">Student ID</font></strong></div></td>
					  <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>Student Name</strong></font></div></td>
					  <td width="10%" class="thinborder"><div align="center"><strong><font size="1">Course-YR</font></strong></font></div></td>
					  <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>Curriculum YR</strong></font></div></td>
					  <td width="10%" class="thinborder"><div align="center"><strong><font size="1">#of Subjects having Same Section</font></strong></div></td>
					  <td width="10%" class="thinborder"><div align="center"><strong><font size="1">Is Enrolled?</font></strong></div></td>
					  <td width="10%" class="thinborder"><div align="center"><strong><font size="1">Select<br>
					  <input type="checkbox" name="sel_all" onClick="SelALL();"></font></strong></div></td>
					</tr>
					<%
					int iCount = 0;
					String strBGColor = "";
					String strJustAdded = WI.fillTextValue("stud_id");
					
				for(int i=0; i< vStudAdvisedList.size(); i += 12){
					strBGColor = "";
					if(WI.getStrValue(vStudAdvisedList.elementAt(i + 9)).equals("1")) {
						strTemp = "Yes";
						strBGColor = " bgcolor='#999999'";
					}
					else	
						strTemp = "No";
						
					if(vStudAdvisedList.elementAt(i + 10).equals("1")) //temp stud..
						strBGColor = " bgcolor='#dddddd'";
						
					if(strJustAdded.equals(vStudAdvisedList.elementAt(i)))
						strBGColor = " bgcolor='#6699FF'";
				 %>
					<tr<%=strBGColor%>>
						<td class="thinborder"><%=i/12 + 1%>.</td>
					  	<td height="20" class="thinborder"><%=(String)vStudAdvisedList.elementAt(i)%></td>
						<td class="thinborder"> <%=(String)vStudAdvisedList.elementAt(i+1)%> </td>
						<td align="center" class="thinborder"><%=vStudAdvisedList.elementAt(i+3)%> <%=WI.getStrValue(vStudAdvisedList.elementAt(i+4))%>
						<%=WI.getStrValue((String)vStudAdvisedList.elementAt(i+7)," - ","","")%></td>
						<td align="center" class="thinborder"><%=vStudAdvisedList.elementAt(i+5)%> <%=WI.getStrValue(vStudAdvisedList.elementAt(i+6))%></td>				
						<td align="center" class="thinborder"><%=(String)vStudAdvisedList.elementAt(i+2)%></td>
						<td align="center" class="thinborder"><%=strTemp%></td>
						<td align="center" class="thinborder">
						<%if(strTemp.equals("No") && vStudAdvisedList.elementAt(i + 11) == null){%>
							<input type="checkbox" name="useri_<%=++iCount%>" value="<%=vStudAdvisedList.elementAt(i+8)%>">
							<input type="hidden" name="is_temp_<%=iCount%>" value="<%=vStudAdvisedList.elementAt(i+10)%>">						</td>
						<%}else if(vStudAdvisedList.elementAt(i + 11) != null){%>
							<%=vStudAdvisedList.elementAt(i + 11)%>
						<%}else{%>N/A<%}%>
					</tr>
				 <%}%>
				 <input type="hidden" name="max_disp" value="<%=iCount%>">
				  </table>
				  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 					<tr>
					  <td align="center">
					  	<input type="button" name="12" value=" Remove Advising >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="RemoveAdvising();">					  </td>
				    </tr>
				  </table>
			</div>		  </td>
		</tr>
<%}%>
<%if(vBlockSecSchDetail != null) {%>
	  <tr>
		  <td height="24">&nbsp;</td>
		  <td style="font-size:14px;"> ID/Last Name </td>
	      <td>
		  <input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox" style="font-size:14px;"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  		onKeyUp="AjaxMapName('1');">
	  
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:500"></label>	  	 </td>
	      <td>&nbsp;</td>
	  </tr>
	  <tr>
	    <td height="24">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>
			<input type="button" name="12" value=" Add Student To Section >>> " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="CallOnLoad('1');AddStudent();">		  
		</td>
	    <td>&nbsp;</td>
      </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8" style="font-size:14px; font-weight:bold; color:#FF0000">&nbsp;&nbsp;&nbsp;&nbsp; 
	  <%if(!bolAllowAdvising) {%>
	  	Advising is not allowed. Please contact System admin
	  <%}%>
	  
	  </td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="8" bgcolor="#A49A6A" align="center">&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
<input type="hidden" name="course_index" value="<%=WI.fillTextValue("course_index")%>">
<input type="hidden" name="major_index" value="<%=WI.fillTextValue("major_index")%>">
<input type="hidden" name="year_level" value="<%=WI.fillTextValue("year_level")%>">
<input type="hidden" name="cy_fr" value="<%=WI.fillTextValue("cy_fr")%>">

<input type="hidden" name="show_hide_stat" value="<%=WI.fillTextValue("show_hide_stat")%>">
<input type="hidden" name="remove_advising" value="<%=WI.fillTextValue("remove_advising")%>">

<input type="hidden" name="add_stud">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
