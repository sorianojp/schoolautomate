<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.offlineRegd.page_action.value = "";
	document.offlineRegd.submit();
}
function updateGraduating(strInfoIndex) {
	document.offlineRegd.page_action.value = "";
	document.offlineRegd.update_graduating.value = "1";
	document.offlineRegd.info_index.value = strInfoIndex;
	document.offlineRegd.submit();
}
function updateAttcNB(strInfoIndex) {
	document.offlineRegd.page_action.value = "";
	document.offlineRegd.update_attcnb.value = "1";
	document.offlineRegd.info_index.value = strInfoIndex;
	document.offlineRegd.submit();
}
function updateSection(strInfoIndex, strSection, objSection) {
	if(objSection[objSection.selectedIndex].value == strSection)
		return;
		
	if(!confirm('Are you sure you want to change the section.'))
		return;
	document.offlineRegd.page_action.value = "";
	document.offlineRegd.update_section.value = objSection[objSection.selectedIndex].value;
	document.offlineRegd.info_index.value = strInfoIndex;
	document.offlineRegd.submit();
}
function updateReturnee(strInfoIndex) {
	document.offlineRegd.page_action.value = "";
	document.offlineRegd.update_isreturnee.value = "1";
	document.offlineRegd.info_index.value = strInfoIndex;
	document.offlineRegd.submit();
}
function PageAction(strInfoIndex,strPageAction)
{
	document.offlineRegd.page_action.value = strPageAction;
	document.offlineRegd.info_index.value = strInfoIndex;
	document.offlineRegd.submit();
}
function PrepareToEdit(strInfoIndex)
{
	document.offlineRegd.page_action.value = "";
	document.offlineRegd.info_index.value = strInfoIndex;
	document.offlineRegd.prepareToEdit.value = "1";
	document.offlineRegd.editClicked.value = "1";
	document.offlineRegd.submit();
}
function EditRecord()
{
	document.offlineRegd.page_action.value = "2";
	document.offlineRegd.submit();
}
function AddRecord()
{
	document.offlineRegd.page_action.value = "1";
	document.offlineRegd.submit();
}
function CancelRecord()
{
	location = "./change_stud_critical_info_ncentry.jsp?get_doe=1&stud_id="+document.offlineRegd.stud_id.value;
}
function OpenSearch(strIDInfo) {
	var pgLoc = "../../search/srch_stud.jsp?opner_info=offlineRegd.stud_id";

	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//// - all about ajax..
function AjaxMapName(strPos) {
		var strCompleteName;
		strCompleteName = document.offlineRegd.stud_id.value;
		if(strCompleteName.length < 3) {
			document.getElementById("coa_info").innerHTML = "";
			return;
		}

		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	/** do not do anything **/
	document.offlineRegd.stud_id.value = strID;
	document.offlineRegd.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
	//document.offlineRegd.charge_to_name.value = strName;
}
function UpdateNameFormat(strName) {
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateIDRange(strCurHistIndex, strIDRangeSYF) {
	if(true)
		return;
	
	strNewIDSY = prompt('Please enter new SY for ID Range');
	if(strNewIDSY == null || strNewIDSY == '')
		return;
	document.offlineRegd.new_id_range.value = strNewIDSY;
	document.offlineRegd.new_id_range_chi.value = strCurHistIndex;
	document.offlineRegd.new_id_range_syf.value = strIDRangeSYF;
	document.offlineRegd.submit();
}
</script>

<body bgcolor="#D2AE72" onLoad="document.offlineRegd.stud_id.focus()">
<%@ page language="java" import="utility.*,student.ChangeCriticalInfo,enrollment.SubjectSection,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	Vector vStudInfo = null;
	Vector vEditInfo = null;
	boolean bolUseEditValue = false;
	if(WI.fillTextValue("editClicked").compareTo("1") ==0)
		bolUseEditValue = true;

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";

	int i = 0; int j = 0;

	Vector vTemp = new Vector();
	String strCYTo = null;
	String strDegreeType = null;

	String strTemp = null;String strTemp2 = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","create_old_stud_basicinfo.jsp");
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
														"Admission","Student Info Mgmt",request.getRemoteAddr(),
														"create_old_stud_basicinfo.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

	if(WI.fillTextValue("update_graduating").length() > 0) {
		strTemp = "select is_graduating from stud_curriculum_hist where cur_hist_index = "+WI.fillTextValue("info_index");
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp == null || strTemp.equals("0"))
			strTemp = "1";
		else
			strTemp = "0";
		strTemp = "update stud_curriculum_hist set is_graduating = "+strTemp +
					" where cur_hist_index = "+WI.fillTextValue("info_index");
		dbOP.executeUpdateWithTrans(strTemp, null, null, false);
		//System.out.println("Printing : "+strTemp);
	}
	if(WI.fillTextValue("update_attcnb").length() > 0) {
		strTemp = "select is_attcnb_stud from stud_curriculum_hist where cur_hist_index = "+WI.fillTextValue("info_index");
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp == null || strTemp.equals("0"))
			strTemp = "1";
		else
			strTemp = "0";
		strTemp = "update stud_curriculum_hist set is_attcnb_stud = "+strTemp +" where cur_hist_index = "+WI.fillTextValue("info_index");
		dbOP.executeUpdateWithTrans(strTemp, null, null, false);
		//System.out.println("Printing : "+strTemp);
	}
	if(WI.fillTextValue("update_section").length() > 0) {
		strTemp = "update stud_curriculum_hist set section_name = "+WI.getInsertValueForDB(WI.fillTextValue("update_section"), true, null) +" where cur_hist_index = "+WI.fillTextValue("info_index");
		dbOP.executeUpdateWithTrans(strTemp, null, null, false);
		//System.out.println("Printing : "+strTemp);
	}
	if(WI.fillTextValue("update_isreturnee").length() > 0) {
		strTemp = "select is_returnee from stud_curriculum_hist where cur_hist_index = "+WI.fillTextValue("info_index");
		strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		if(strTemp == null || strTemp.equals("0"))
			strTemp = "1";
		else
			strTemp = "0";
		strTemp = "update stud_curriculum_hist set is_returnee = "+strTemp +" where cur_hist_index = "+WI.fillTextValue("info_index");
		dbOP.executeUpdateWithTrans(strTemp, null, null, false);
		//System.out.println("Printing : "+strTemp);
	}


//end of authenticaion code.
Vector vYrLevelInfo = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
strTemp = WI.fillTextValue("page_action");
Vector vOtherInfo = null;

ChangeCriticalInfo changeInfo = new ChangeCriticalInfo();
SubjectSection SS 	= new SubjectSection();
vStudInfo = changeInfo.getStudentEntryInfo(dbOP,WI.fillTextValue("stud_id"));

Vector vCITIDRange = new Vector();
boolean bolIsCIT = strSchCode.startsWith("CIT");

if(vStudInfo == null)
	strErrMsg  = changeInfo.getErrMsg();
else if(bolIsCIT){
	String strNewIDRangeCHI = WI.fillTextValue("new_id_range_chi");
	String strNewIDRange    = WI.fillTextValue("new_id_range");//which is new range: range_sy_from - range_sy_to 
	String strNewIDRangeSYF = WI.fillTextValue("new_id_range_syf");//sy-from of cur hist index table which is eff_fr_sy
	
	if(strNewIDRange.length() > 0 && strNewIDRangeCHI.length() > 0 && strNewIDRangeSYF.length() > 0) {
		//I have to find new ID Range index.
		String strNewIDRangeIndex = "select id_range_index from fa_cit_idrange where "+strNewIDRange+" between range_sy_from and range_sy_to and eff_fr_sy = "+strNewIDRangeSYF;
		strNewIDRangeIndex = dbOP.getResultOfAQuery(strNewIDRangeIndex, 0);
		if(strNewIDRangeIndex == null)
			strErrMsg = "NO ID Range defined for : "+strNewIDRange+" in school year "+strNewIDRangeSYF;
		else {
			strTemp = "update stud_curriculum_hist set id_range_ref = "+strNewIDRangeIndex+", id_range_sy ="+strNewIDRange+" where cur_hist_index = "+strNewIDRangeCHI;
			if(dbOP.executeUpdateWithTrans(strTemp, (String)request.getSession(false).getAttribute("login_log_index"), "STUD_CURRICULUM_HIST", true) == -1)
				strErrMsg= "Failed to update ID Range Information.";
			else	
				strErrMsg = "ID Range Successfully updated.";  
		}
		
	}
	
}

if(strErrMsg == null && strTemp.length() > 0 && vStudInfo != null && vStudInfo.size() > 0)//edit/delete.
{
	if(changeInfo.operateOnStudCurriculumHist(dbOP,request,(String)vStudInfo.elementAt(0),Integer.parseInt(strTemp)) == null)
		strErrMsg = changeInfo.getErrMsg();
	else {
		//if CIT, and if this is the latest Course, i have to update CIT_ID_PRINTING table.
		if(bolIsCIT) {
			String strCourseCode = null;
			String strMajorCode  = null;
			
			dbOP.commitOP();
			dbOP.forceAutoCommitToTrue();
			
			String strSQLQuery = "select sy_from, semester, course_offered.course_code, major.course_code, course_offered.course_index, "+
				"major.major_index from stud_curriculum_hist join semester_sequence on (semester_val = semester) "+
				"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
				"left join major on (major.major_index = stud_curriculum_hist.major_index) "+
				"where stud_curriculum_hist.is_valid = 1 and user_index = "+(String)vStudInfo.elementAt(0)+
				" order by sy_from desc, sem_order desc";
			java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);//System.out.println(strSQLQuery);
			if(rs.next()) {
				if(WI.fillTextValue("sy_from").equals(rs.getString(1)) && WI.fillTextValue("semester").equals(rs.getString(2)) ) {
					strCourseCode = rs.getString(3);
					strMajorCode  = rs.getString(4);
				}
			}
			rs.close();
			if(strCourseCode != null) {//I have to update course-major in cit_id_printing
				if(strMajorCode != null)
					strCourseCode = strCourseCode +" - "+strMajorCode;
				strSQLQuery = "update CIT_ID_PRINTING set COURSE_MAJOR = "+WI.getInsertValueForDB(strCourseCode, true, null)+
          						" where STUDENT_INDEX = "+(String)vStudInfo.elementAt(0);
        		dbOP.executeUpdateWithTrans(strSQLQuery, null, null, false);
				//System.out.println(strSQLQuery);
			}
		
		}
		strErrMsg = "Operation successful";
		strPrepareToEdit = "";
	}
}

if(vStudInfo != null)
{
	vYrLevelInfo =changeInfo.operateOnStudCurriculumHist(dbOP,request,(String)vStudInfo.elementAt(0),4);
	if(vYrLevelInfo == null)
		strErrMsg = changeInfo.getErrMsg();
}
if(strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = changeInfo.operateOnStudCurriculumHist(dbOP,request,(String)vStudInfo.elementAt(0),3);
	if(vEditInfo == null)
	{
		strErrMsg = changeInfo.getErrMsg();
		bolUseEditValue = false;
	}
}
if(vStudInfo != null && bolIsCIT) {
	String strSQLQuery = "select cur_hist_index, id_range_sy from stud_curriculum_hist where id_range_sy is not null and is_valid  = 1 and user_index = "+(String)vStudInfo.elementAt(0);
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()){
		vCITIDRange.addElement(rs.getString(1));
		vCITIDRange.addElement(new Integer(rs.getInt(2)));
	}
	rs.close();
}



String[] astrConvertToSem={"Summer","1st Sem","2nd Sem","3rd Sem", "4th Sem"};
String[] astrConvertToYr = {"","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr"};
if(bolUseEditValue)
	strTemp = (String)vEditInfo.elementAt(5);
else
	strTemp = WI.fillTextValue("course_index");
strDegreeType = dbOP.mapOneToOther("COURSE_OFFERED","COURSE_INDEX",strTemp,"DEGREE_TYPE", " and is_valid=1 and is_del=0");

boolean bolIsFatima = strSchCode.startsWith("FATIMA");
boolean bolIsUC     = strSchCode.startsWith("UC");
boolean bolIsVMA    = strSchCode.startsWith("VMA");
boolean bolIsSPC    = strSchCode.startsWith("SPC");
boolean bolIsDLSHSI = strSchCode.startsWith("DLSHSI");

	Vector vLockInfo = new Vector();
	if(vStudInfo != null && vStudInfo.size() > 0) {
		enrollment.SetParameter paramGS = new enrollment.SetParameter();
		vLockInfo = paramGS.operateOnLockFeeLD(dbOP,request,5);
		//System.out.println(vLockInfo);
		if(vLockInfo == null)
			vLockInfo = new Vector();
	}

%>
<form action="./change_stud_critical_info_ncentry.jsp" method="post" name="offlineRegd">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          STUDENT COURSE INFORMATION UPDATE PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" width="2%"></td>
	  <td width="98%" > <strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="13%" >Student ID :</td>
      <td width="23%" ><input type="text" name="stud_id" size="18" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">      </td>
      <td width="8%" height="25"><!--<a href="javascript:OpenSearch()">Search ID</a>&nbsp;-->
	  <input type="image" src="../../images/form_proceed.gif"></td>
      <td width="54%"><label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF"></label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4" >NOTE : If student is enrolled thru' system,
      only curriculum year can be changed in this page.</td>
    </tr>
    <tr>
      <td colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="14%" >Name: </td>
      <td width="24" colspan="5" ><%=(String)vStudInfo.elementAt(1)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Entry Status:</td>
      <td colspan="5"><%=(String)vStudInfo.elementAt(10)%></td>
    </tr>
<%if(false){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td >Course/Major: </td>
      <td colspan="5"><%=(String)vStudInfo.elementAt(2)%>
        <%if(vStudInfo.elementAt(3) != null){%>
        <%=(String)vStudInfo.elementAt(3)%>
        <%}%>
        (<%=(String)vStudInfo.elementAt(11)%> - <%=(String)vStudInfo.elementAt(12)%>)      </td>
    </tr>
<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#66CCFF" align="center">
      <td width="12%" style="font-size:9px; font-weight:bold" class="thinborder" height="20">SY - TERM</td>
      <td align="center" style="font-size:9px; font-weight:bold" width="50%" class="thinborder">COURSE/MAJOR(CURRICULUM YR)</td>
      <td width="10%" style="font-size:9px; font-weight:bold" class="thinborder">DATE ENROLLED </td>
      <td width="5%" style="font-size:9px; font-weight:bold" class="thinborder"> Status </td>
<%if(bolIsFatima){%>
      <td width="8%" style="font-size:9px; font-weight:bold" class="thinborder">Is Graduating </td>
<%}if(bolIsUC){%>
      <td width="8%" style="font-size:9px; font-weight:bold" class="thinborder">Is ATTC/NB </td>
<%}%>
      <td width="8%" style="font-size:9px; font-weight:bold" class="thinborder">Is Returnee </td>
<%if(bolIsVMA || bolIsSPC){%>
      <td width="8%" style="font-size:9px; font-weight:bold" class="thinborder">Section Assigned </td>
<%}if(bolIsCIT){%>
      <td width="5%" style="font-size:9px; font-weight:bold" class="thinborder">ID Range SY </td>
      <%}%>
      <td width="15%" style="font-size:9px; font-weight:bold" class="thinborder">EDIT / DELETE</td>
    </tr>
    <%
if(vYrLevelInfo != null) {
boolean bolIsFeeLocked = false;
int iIndexOf = 0;

	for(i = 0; i< vYrLevelInfo.size() ;i +=17){
		vOtherInfo = (Vector)vYrLevelInfo.elementAt(i + 16);
		
		strTemp = (String)vYrLevelInfo.elementAt(i+1)+" - "+(String)vYrLevelInfo.elementAt(i+3);
		if(vLockInfo.indexOf(strTemp) > -1)
			bolIsFeeLocked = true;
		else
			bolIsFeeLocked = false;
			
		iIndexOf = vCITIDRange.indexOf((String)vYrLevelInfo.elementAt(i));
		if(iIndexOf == -1) 
			strTemp = "&nbsp;";
		else	
			strTemp = ((Integer)vCITIDRange.elementAt(iIndexOf + 1)).toString();
		%>
    <tr>
      <td height="20" class="thinborder"><%=(String)vYrLevelInfo.elementAt(i+1)%>-<%=((String)vYrLevelInfo.elementAt(i+2)).substring(2)%>
        - <%=astrConvertToSem[Integer.parseInt((String)vYrLevelInfo.elementAt(i+3))]%></td>
      <td class="thinborder"><%=(String)vYrLevelInfo.elementAt(i+7)%>
	  <%
	  if(vYrLevelInfo.elementAt(i+8) != null){%>
	  - <%=(String)vYrLevelInfo.elementAt(i+8)%>
	  <%}%>
        (<%=(String)vYrLevelInfo.elementAt(i+9)%> - <%=(String)vYrLevelInfo.elementAt(i+10)%>)</td>
      <td class="thinborder"><%=WI.getStrValue(vYrLevelInfo.elementAt(i+15),"<font style='font-size:9px;font-weight:bold;color=red'>Not enrolled</font>")%></td>
      <td class="thinborder"><%=(String)vYrLevelInfo.elementAt(i+12)%></td>
      <%if(bolIsFatima){%>
      <td class="thinborder">
		  <%if(vOtherInfo.elementAt(0).equals("0")) {%>No<%}else{%><font style="font-weight:bold; font-size:9px; color:#FF0000">Yes</font><%}%>
	  <%if(!bolIsFeeLocked){%>
		  <br>
		  <a href="javascript:updateGraduating('<%=(String)vYrLevelInfo.elementAt(i)%>');">Toggle</a>	
	  <%}%>	  </td>
<%}if(bolIsUC){%>
      <td class="thinborder"><%if(vOtherInfo.elementAt(1).equals("0")) {%>No<%}else{%><font style="font-weight:bold; font-size:9px; color:#FF0000">Yes</font><%}%>
	  <%if(!bolIsFeeLocked){%>
		  <br>
		  <a href="javascript:updateAttcNB('<%=(String)vYrLevelInfo.elementAt(i)%>');">Toggle</a>	  </td>
	  <%}%>  
<%}%>
      <td class="thinborder">
	  <%if(vOtherInfo.elementAt(2).equals("0")) {%>No<%}else{%><font style="font-weight:bold; font-size:9px; color:#FF0000">Yes</font><%}%>
	  <%if(!bolIsFeeLocked){%>
		  <br>
		  <a href="javascript:updateReturnee('<%=(String)vYrLevelInfo.elementAt(i)%>');">Toggle</a>
	  <%}%>	  </td>
<%if(bolIsVMA || bolIsSPC){%>
      <td class="thinborder" align="center">
		<select name="section_name_<%=i%>" onChange="updateSection('<%=(String)vYrLevelInfo.elementAt(i)%>','<%=(String)vOtherInfo.elementAt(3)%>',document.offlineRegd.section_name_<%=i%>)" style="font-size:11px;">
			<option value=""></option>
<%if(bolIsVMA){%>
          <%=dbOP.loadCombo("vma_section.section_name","vma_section.section_name"," from vma_section order by section_name asc", (String)vOtherInfo.elementAt(3), false)%>
<%}else{%>
          <%=dbOP.loadCombo("distinct e_sub_section.section","e_sub_section.section"," from e_sub_section where is_valid = 1 and offering_sy_from = "+vYrLevelInfo.elementAt(i+1)+
		  " and offering_sem = "+vYrLevelInfo.elementAt(i+3)+" order by e_sub_section.section asc", (String)vOtherInfo.elementAt(3), false)%>
<%}%>
		</select>	  </td>
<%}if(bolIsCIT){%>
      <td class="thinborder" align="center" onDblClick="UpdateIDRange('<%=(String)vYrLevelInfo.elementAt(i)%>','<%=(String)vYrLevelInfo.elementAt(i+1)%>')"><%=strTemp%></td>
<%}%>
      <td class="thinborder">
	  <%if(!bolIsFeeLocked){%>
		  <%if(iAccessLevel > 1){%>
		  <a href='javascript:PrepareToEdit("<%=(String)vYrLevelInfo.elementAt(i)%>");'><img src="../../images/edit.gif" border="0"></a>
			&nbsp;
		  <%}if(iAccessLevel ==2){%>
		  <a href='javascript:PageAction("<%=(String)vYrLevelInfo.elementAt(i)%>","0");'><img src="../../images/delete.gif" border="0"></a>
		  <%}else{%>
	  		N/A<%}%>
	  <%}else{%> Fee Locked<%}%></td>
    </tr>
<%}
}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="20" colspan="7">&nbsp;</td>
    </tr>
  </table>
<%if(vEditInfo != null && vEditInfo.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><div align="right">Student Status :</div></td>
      <td>
<%

	if(bolUseEditValue) strTemp = (String)vEditInfo.elementAt(11);
	else strTemp = WI.fillTextValue("status_index");

   if (strSchCode.startsWith("CPU")){
		strTemp2 =" and status <>'balik-aral' and status <>'semi regular'";
	  }else{
	  	strTemp2 = "";
	  }

%>
	  <select name="status_index">
          <%=dbOP.loadCombo("status_index","status",
		  			" from user_status where is_for_student = 1 "+ strTemp2 +" order by status asc",
					strTemp, false)%> </select></td>
    <tr>
      <td height="25"><div align="right">School Year - Term: </div></td>
      <td>
        <%
	  if(bolUseEditValue) strTemp = (String)vEditInfo.elementAt(1);
	  else strTemp = WI.fillTextValue("sy_from");
	  %>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("offlineRegd","sy_from","sy_to")'>
        <%
	  if(bolUseEditValue) strTemp = (String)vEditInfo.elementAt(2);
	  else strTemp = WI.fillTextValue("sy_to");
	  %>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes">
        &nbsp;&nbsp;&nbsp; <select name="semester">
          <option value="0">Summer</option>
          <%
if(bolUseEditValue)
	strTemp = (String)vEditInfo.elementAt(3);
else strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}

		  if (!strSchCode.startsWith("CPU")) {

		  if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}
		  }%>
        </select> </td>
<%
if(strDegreeType != null && strDegreeType.compareTo("4") !=0 && strDegreeType.compareTo("1") !=0){%>
    <tr>
      <td height="25" align="right">Year Level: </td>
      <td><select name="year_level">
          <option value="1">1st</option>
          <%
if(bolUseEditValue)
	strTemp = WI.getStrValue(vEditInfo.elementAt(4));
else strTemp = WI.fillTextValue("year_level");

if(strTemp.compareTo("2") == 0){%>
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
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select>
<%
if(strDegreeType != null && strDegreeType.compareTo("3") ==0){%>
        -
        <select name="prep_prop_stat">
          <option value="1">Preparatory</option>
          <%
if(bolUseEditValue)
	strTemp = WI.getStrValue(vEditInfo.elementAt(13));
else strTemp = WI.fillTextValue("prep_prop_stat");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>Proper</option>
          <%}else{%>
          <option value="2">Proper</option>
          <%}%>
        </select>
<%}%>		</td>
    </tr>
<%}//only if year level and proper is allowed -- for masteral / care giver, it is not necessary.
%>
    <tr>
      <td height="25" align="right">Course</td>
      <td><select name="course_index" onChange="ReloadPage();">
          <%
if(bolUseEditValue)
	strTemp = (String)vEditInfo.elementAt(5);
else strTemp = WI.fillTextValue("course_index");
%>
          <option value="">Select a Course</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where is_valid=1 and is_del=0 order by course_name asc",
				strTemp, false)%> </select></td>
    </tr>
    <tr>
      <td height="25" align="right">Major</td>
      <td><select name="major_index" onChange="ReloadPage();">
          <option></option>
          <%
if(strTemp.length() > 0)
{
if(bolUseEditValue)
	strTemp2 = (String)vEditInfo.elementAt(6);
else strTemp2 = WI.fillTextValue("major_index");
%>
          <%=dbOP.loadCombo("major_index","major_name"," from major where is_del=0 and course_index="+strTemp+" order by major_name asc",
		  		strTemp2, false)%>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25" align="right">Curriculum Year</td>
      <td> <select name="cy_from" onChange="ReloadPage();">
          <%
//get here school year
vTemp = SS.getSchYear(dbOP, strTemp,strTemp2);//System.out.println(vEditInfo);
if(vTemp == null)
	vTemp= new Vector();

if(bolUseEditValue)
	strTemp = (String)vEditInfo.elementAt(9);
else strTemp = WI.fillTextValue("cy_from");
for(i = 0, j=0 ; i< vTemp.size();)
{
	if(	((String)vTemp.elementAt(i)).compareTo(strTemp) == 0)
	{%>
          <option value="<%=(String)vTemp.elementAt(i)%>" selected><%=(String)vTemp.elementAt(i)%></option>
          <%	j = i;
	}
	else{
	%>
          <option value="<%=(String)vTemp.elementAt(i)%>"><%=(String)vTemp.elementAt(i)%></option>
          <%	}
	i = i+2;

}
if(vTemp.size() > 0)
	strCYTo = (String)vTemp.elementAt(j+1);
else
	strCYTo = "";

%>
        </select>
        to <b><%=strCYTo%></b> <input type="hidden" name="cy_to" value="<%=strCYTo%>">
      </td>
    </tr>
    <tr>
      <td width="17%">&nbsp; </td>
      <td width="83%">
        <%
	  if(strPrepareToEdit.compareTo("1") != 0 && iAccessLevel > 1){%>
        <font size="1"><!--<a href="javascript:AddRecord();"><img src="../../images/save.gif" border="0"></a>click
        to add a new entry -->Save feature disabled.</font>
        <%}else if(strPrepareToEdit.compareTo("1") ==0 && iAccessLevel > 1){%>
        <a href="javascript:EditRecord();"><img src="../../images/edit.gif" border="0"></a>
        <font size="1">click to save changes</font> <a href="javascript:CancelRecord();"><img src="../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel &amp; clear entries</font>
        <%}%>
      </td>
    </tr>
  </table>
 <%}
 
 
 }// outer most vStudInfo is not null%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="degree_type" value="<%=strDegreeType%>">
<input type="hidden" name="editClicked" value="">
<%
if(vStudInfo != null && vStudInfo.size() > 0){%>
<input type="hidden" name="stud_index" value="<%=(String)vStudInfo.elementAt(0)%>">
<%}%>

<input type="hidden" name="get_doe" value="1"><!-- get date of enrollment -->
<input type="hidden" name="update_graduating">
<input type="hidden" name="update_attcnb">
<input type="hidden" name="update_section">
<input type="hidden" name="update_isreturnee">

<input type="hidden" name="new_id_range">
<input type="hidden" name="new_id_range_chi">
<input type="hidden" name="new_id_range_syf">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
