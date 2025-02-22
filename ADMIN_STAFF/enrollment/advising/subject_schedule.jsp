<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strDegreeType = WI.fillTextValue("degree_type");
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	boolean bolIsHTC = strSchCode.startsWith("HTC");
	boolean bolIsPhilCST = strSchCode.startsWith("PHILCST");
	boolean bolIsSWU = strSchCode.startsWith("SWU");
	String strStatus = null;


	String strErrMsg = null;
	String strTemp = null;
	boolean[] bolConflict = {false}; // this is passed to getSubjectScheduleTime to check if the subject is conflict with the previous
//long lTime = new java.util.Date().getTime();

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-advising-subject schedule","subject_schedule.jsp");
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
														"Enrollment","ADVISING & SCHEDULING",request.getRemoteAddr(),
														"subject_schedule.jsp");
//switch off security if called from online advisign page of student... this page can't be refreshed.
if(WI.fillTextValue("online_advising").compareTo("1") ==0)
	iAccessLevel = 2;

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

String strCurIndex = request.getParameter("cur_index");

String strOfferingYrFrom = request.getParameter("syf");
String strOfferingYrTo = request.getParameter("syt");
String strOfferingSem = request.getParameter("semester");

String strCourseIndex = WI.fillTextValue("course_index");
String strMajorIndex = WI.fillTextValue("major_index");
String strSubIndex = WI.fillTextValue("sub_index");
String strSubCode = "";



//System.out.println("I am here.");
//long lT = new java.util.Date().getTime();
Advising advising = new Advising(); enrollment.SubjectSection SS = new enrollment.SubjectSection();
Vector vSectionDetail = null;
Vector vSchedule = null;
Vector vSubInfo = advising.getSubjectInfo(dbOP,strCurIndex,strDegreeType);


if(vSubInfo == null)
	strErrMsg = advising.getErrMsg();
else /// do all processing here.
{
	if(WI.fillTextValue("sec_startsWith").length() > 0 && !strSchCode.startsWith("CIT")) {
		//if it is a full section, do not filter.. 
		strTemp = WI.fillTextValue("sec_startsWith");
		strTemp = "select sub_sec_index from e_sub_section where offering_sy_from = "+strOfferingYrFrom+
			" and offering_sem = "+strOfferingSem+" and is_valid = 1 and section = "+
			WI.getInsertValueForDB(strTemp, true, null);
		if(dbOP.getResultOfAQuery(strTemp, 0) == null)
			advising.strSecStartsWith = WI.fillTextValue("sec_startsWith");
			
			
	}
		//if (!strSchCode.startsWith("CPU") && !strSchCode.startsWith("CIT")) // stub coding.. section not required..
		//	advising.strSecStartsWith = WI.fillTextValue("sec_startsWith");

	if (!strSchCode.startsWith("CPU")){
		vSectionDetail = advising.getSubSectionDetail(dbOP,strCourseIndex,strMajorIndex,strSubIndex,
														strOfferingYrFrom,strOfferingYrTo,strOfferingSem,
														strDegreeType,null);
		
//		System.out.println(" vSectionDetail : " + vSectionDetail);
	}
	else{ // for CPU
	
		strSubCode = (String)vSubInfo.elementAt(0);
		if(strSubCode.toLowerCase().startsWith("nstp")){
			if ( WI.fillTextValue("nstp_val").length() > 0) {
				strSubCode = CommonUtil.truncateALLBlankSpace(strSubCode) + "-" + 
						WI.fillTextValue("nstp_val");
				strSubIndex = dbOP.mapOneToOther("subject","sub_code","'" + strSubCode + "'",
								"sub_index"," and is_del = 0"); 
			}
		}

		vSectionDetail = advising.getSubSectionDetailCPU(dbOP,strCourseIndex,strMajorIndex,strSubIndex,
														strOfferingYrFrom,strOfferingYrTo,strOfferingSem,
														strDegreeType,request);
														
//		System.out.println("vSectionDetail : "  + vSectionDetail);
	}
															
	if(vSectionDetail == null || vSectionDetail.size() == 0)
		strErrMsg = advising.getErrMsg();
}

//System.out.println( (lT - new java.util.Date().getTime())/100);
Vector vForcedBlock = null;
boolean bolIsETO = new enrollment.SetParameter().bolIsETO(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
if(vSectionDetail != null && vSectionDetail.size() > 0) {
	vForcedBlock = new enrollment.SubjectSection().getForcedBlockSectionList(dbOP, request, request.getParameter("syf"), request.getParameter("semester"));
	if(vForcedBlock != null && vForcedBlock.size() > 0) {
		for(int i=0; i< vSectionDetail.size(); i += 8){
			if(vForcedBlock.indexOf(vSectionDetail.elementAt(i+2)) == -1)
				continue;
			vSectionDetail.remove(i);vSectionDetail.remove(i);vSectionDetail.remove(i);vSectionDetail.remove(i);
			vSectionDetail.remove(i);vSectionDetail.remove(i);vSectionDetail.remove(i);vSectionDetail.remove(i);
			i = i - 8;
		}
	}
}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Subject Schedule Reference Page</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style>
.nav {
     /**color: #000000;**/
     /**background-color: #FFFFFF;**/
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     /**background-color: #FAFCDD;**/
     background-color:#BCDEDB;
}

</style>

</head>
<script language="JavaScript">
function RefreshPage(){
	document.subschedule.submit();
}
function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}
function copyValueToParent()
{

	if(document.subschedule.sub_sec_index.value == "0" 
		|| document.subschedule.sec_name_value.value == "0")
	{
		window.close();
		return;
	}
	var iLineNum = document.subschedule.line_number.value;

	eval('window.opener.document.'+document.subschedule.form_name.value+'.'+document.subschedule.sec_index_name.value+'.value=\"'+document.subschedule.sub_sec_index.value+'\"');
	eval('window.opener.document.'+document.subschedule.form_name.value+'.'+document.subschedule.sec_name.value+'.value=\"'+document.subschedule.sec_name_value.value+'\"');
	eval('window.opener.document.'+document.subschedule.form_name.value+'.'+document.subschedule.sec_name.value+'.value=\"'+document.subschedule.sec_name_value.value+'\"');
	
	var strRowClicked = "_"+document.subschedule.row_clicked.value;
	//alert(document.getElementById(strRowClicked).innerHTML);
	var objParent;
	eval('objParent=window.opener.document.getElementById(\"_'+iLineNum+'\")');
	if(objParent) {
		objParent.innerHTML = document.getElementById(strRowClicked).innerHTML;
	}
	
	//eval('window.opener.document.getElementById(\"_'+iLineNum+'\").innerHTML=\"'+document.getElementById(strRowClicked).innerHTML+'\"');
	
	//eval('window.opener.document.'+document.subschedule.form_name.value+'.checkbox'+document.subschedule.index_of_.value+'.checked=true');

	if(document.subschedule.line_number.value.length > 0) {
		var iLineNum = document.subschedule.line_number.value;
		var isChecked = false;
		eval('isChecked=window.opener.document.'+document.subschedule.form_name.value+'.checkbox'+iLineNum+'.checked');

		if(document.subschedule.add_oc.value == '3') {//change schedule.. do not check anymore load units.. 
			if(!isChecked) {
				var iAddCount = window.opener.document.chngsubject.addSubCount.value;
				++iAddCount;
				if(iAddCount == 0)
					iAddCount = 1;
				window.opener.document.chngsubject.addSubCount.value = iAddCount;
				eval('window.opener.document.'+document.subschedule.form_name.value+'.checkbox'+iLineNum+'.checked=true');
				//alert(iAddCount);
			}
			window.close();
			return;
		}
		
		if(!isChecked) {
			var maxAllowedLoad = "";
			eval('maxAllowedLoad=window.opener.document.'+document.subschedule.form_name.value+'.maxAllowedLoad.value');
			//maxAllowedLoad = "1";
			
			var totalLoad;
			if(document.subschedule.add_oc.value == '1')
				eval('totalLoad=window.opener.document.'+document.subschedule.form_name.value+'.sub_load_duplicate.value');
			else	
				eval('totalLoad=window.opener.document.'+document.subschedule.form_name.value+'.sub_load.value');
		
			var curLoad;
			eval('curLoad=window.opener.document.'+document.subschedule.form_name.value+'.ut'+iLineNum+'.value');
		
			totalLoad = Number(totalLoad) + Number(curLoad);
			
			if( Number(totalLoad) > Number(maxAllowedLoad))//just copy the section, but do not select it.. 
				alert("Student can't take more than allowed load <"+maxAllowedLoad+">.Please re-adjust load.");
			else {		
				eval('window.opener.document.'+document.subschedule.form_name.value+'.checkbox'+iLineNum+'.checked=true');
		
				if(document.subschedule.add_oc.value == '1')
					eval('window.opener.document.'+document.subschedule.form_name.value+'.sub_load_duplicate.value=totalLoad');
				else	
					eval('window.opener.document.'+document.subschedule.form_name.value+'.sub_load.value=totalLoad');
			}
		}
	}
	window.close();
	return;
}
function AssignSecIndex(subSecIndex,section, row_id)
{
	document.subschedule.sub_sec_index.value = subSecIndex;
	document.subschedule.sec_name_value.value = section;
	document.subschedule.row_clicked.value = row_id;
}
function rowDBLClicked(strStatus, strConflict, subSecIndex,section, row_id) {
	<%if(!bolIsETO){%>
		if(strStatus == 'Closed' || strStatus == '<%if(!bolIsSWU){%>Closed**<%}else{%>For Dissolve<%}%>') {
			alert("Copy Failed. Offering is Closed");
			return;
		}
		if(strConflict == 'true') {
			alert("Copy Failed. Conflict offering.");
			return;
		}
	<%}else{%>
		if(strStatus == 'Closed' || strStatus == '<%if(!bolIsSWU){%>Closed**<%}else{%>For Dissolve<%}%>') {
			if(!confirm("Offering is closed. Are you sure you want to allow?"))
				return;
		}
		if(strConflict == 'true') {
			if(!confirm("Offering is having conflict. Are you sure you want to allow?"))
				return;
		}
	<%}%>
	this.AssignSecIndex(subSecIndex,section, row_id);
	this.copyValueToParent();
}
</script>
<body bgcolor="#D2AE72">
<form name="subschedule" action="./subject_schedule.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          SUBJECT SCHEDULE PAGE ::::</strong></font></div></td>
    </tr>
    
<%
if(strErrMsg != null)
{%>	<tr bgcolor="#FFFFFF">
      <td width="2%" height="25">&nbsp;</td>
      <td width="98%"><%=strErrMsg%></td>

    </tr>
<%dbOP.cleanUP();return;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td  width="2%" height="25">&nbsp;</td>
      <td width="28%" style="font-size:11px;">Code: <strong><%=(String)vSubInfo.elementAt(0)%></strong></td>
      <td style="font-size:11px;">Name: <strong><%=(String)vSubInfo.elementAt(1)%></strong></td>
      <td width="33%" style="font-size:11px;">Units: <strong>
<%if(strDegreeType.compareTo("1") ==0 || strDegreeType.compareTo("2") ==0){%>
		<%=(String)vSubInfo.elementAt(3)%>
<%}else{%>
	  	<%=Float.parseFloat((String)vSubInfo.elementAt(3))+Float.parseFloat((String)vSubInfo.elementAt(4))%> (<%=(String)vSubInfo.elementAt(3)%> - Lec, <%=(String)vSubInfo.elementAt(3)%> - Lab) 
<%}%>
	  </strong></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="9"><div align="center">SUBJECT
          SCHEDULES </div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td width="1%" height="25">&nbsp;</td>
      <td colspan="2" height="25">
	  <%if(bolIsSWU){
	  	strTemp = WI.fillTextValue("include_force_closed");
	  	if(strTemp.equals("1"))
	  		strErrMsg = "checked";
		else
			strErrMsg = "";
	  %>
	  <input type="checkbox" name="include_force_closed" value="1" <%=strErrMsg%> onClick="RefreshPage()">
	  	Click to include <font color="#FF0000"><strong>For Dissolve</strong></font> Section
	  
	  <%}%>
	  </td>
      <td width="16%" height="25" colspan="6">
	  <a href="javascript:copyValueToParent();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
	  </td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0">
    <tr bgcolor="#CCCCCC">
      <%if(bolIsPhilCST || bolIsHTC){%>
	  	<td width="10%" style="font-size:9px; font-weight:bold" align="center"><%if(bolIsHTC){%>TERM<%}else{%>OFFERING CODE<%}%></td>
	  <%} if (!strSchCode.startsWith("CPU"))
			strTemp = "SECTION<br>(ROOM #)";
		else
			strTemp = "STUB CODE<br>(ROOM #)";
	%>	
	
      <td width="14%" height="25"><div align="center"><strong><font size="1"><%=strTemp%></font></strong></div></td>
      <td width="25%"><div align="center"><font size="1"><strong>SCHEDULE (DAYS/TIME) </strong></font></div></td>
	<% if (!strSchCode.startsWith("CPU"))
			strTemp = "COURSE OFFERING THE SUBJECT";
		else
			strTemp = "SECTION";
	%>
      <td width="30%"><div align="center"><font size="1"><strong><%=strTemp%></strong></font></div></td>
<!--      <td width="7%"><div align="center"><font size="1"><strong>REGULAR
          / IRREGULAR</strong></font></div></td>-->
      <td width="8%"><div align="center"><strong><font size="1">MAX. NO. OF STUDENTS</font></strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>NO.
          OF STUDENTS ENROLLED</strong></font></div></td>
      <td width="6%"><div align="center"><strong><font size="1">STATUS</font></strong></div></td>
      <td width="7%"><div align="center"><font size="1"><strong>SELECT</strong></font></div></td>
    </tr>

<%
int iIndexOf = 0;
String strConflictSub = null;
boolean bolForDissolve = false;
strStatus = null;//System.out.println(vSectionDetail.size());
String strSchedule = null;//System.out.println(" I am here. 1");
for(int i=0; i< vSectionDetail.size(); ++i){
bolConflict[0] = false;
bolForDissolve = false;
if(vSectionDetail.elementAt(i+6) == null)
	vSectionDetail.setElementAt("0",i+6);
	
if(vSectionDetail.elementAt(i+6) != null && vSectionDetail.elementAt(i+7) != null &&
	Integer.parseInt((String)vSectionDetail.elementAt(i+6)) <= Integer.parseInt((String)vSectionDetail.elementAt(i+7)))
{
	strStatus = "Closed";
}
else
	strStatus = "Open";
	
//System.out.println(Integer.parseInt((String)vSectionDetail.elementAt(i+6)));	
//System.out.println(Integer.parseInt((String)vSectionDetail.elementAt(i+7)));	
	
//Also i have to check if it is force closed.. 
if(advising.vForceClosedSection.indexOf(vSectionDetail.elementAt(i+1)) > -1){
	strStatus = "Closed**";
	if(bolIsSWU){
		if(WI.fillTextValue("include_force_closed").length() == 0){
			i+=7;//dont show if for Dissolve
			continue;
		}else{
			strStatus = "For Dissolve";
			bolForDissolve = true;
		}
	}
}
	
	strSchedule = null;
/**/
advising.vConflictSubList = new Vector();

strSchedule = advising.getSubjectScheduleTime(dbOP,(String)vSectionDetail.elementAt(i+1),
	  	request.getParameter("sec_index_list"),bolConflict,request.getParameter("IS_FOR_LAB"),
		request.getParameter("lab_list"),request.getParameter("NO_CONFLICT"),
		request.getParameter("no_conflict_list"),strSchCode);
if(strSchedule == null && !strSchCode.startsWith("CPU")){
	i = i+7;
	continue;
}
/**/
//strRoomNoUsedInSchJSP has the room information. %>
   <tr bgcolor="#FFFFFF" onDblClick="rowDBLClicked('<%=strStatus%>','<%=bolConflict[0]%>',
		'<%=(String)vSectionDetail.elementAt(i+1)%>','<%=WI.getStrValue((String)vSectionDetail.elementAt(i+2))%>', '<%=i%>');"
   class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off')">
     <%if(bolIsPhilCST || bolIsHTC){%><td align="center" style="font-size:11px;">
	 <%=WI.getStrValue(SS.convertSubSecIndexToOfferingCount(dbOP,request,(String)vSectionDetail.elementAt(i+1),strOfferingYrFrom,strOfferingSem,strSchCode), "&nbsp;")%>
	 </td>
	<%} if (!strSchCode.startsWith("CPU"))
			strTemp = (String)vSectionDetail.elementAt(i+2);
		else
			strTemp = (String)vSectionDetail.elementAt(i+1);
	%>	   
   
      <td height="24" align="center" style="font-size:11px;"><strong><font color="#FF0000"><%=strTemp%></font></strong>
	  <br>(<%=advising.strRoomNoUsedInSchJSP%>)</td>
      <td align="center" style="font-size:11px;">
	  <label id="_<%=i%>"><%=WI.getStrValue(strSchedule,"TBA")%></label> </td>  
	<% if (!strSchCode.startsWith("CPU"))
			strTemp = WI.getStrValue(vSectionDetail.elementAt(i+3),"For all course");
		else
			strTemp = WI.getStrValue((String)vSectionDetail.elementAt(i+2),"OPEN FOR ALL");
			
		if (strTemp.equals("*")) 
			strTemp = "OPEN FOR ALL";
	%>	  
      <td align="center" style="font-size:11px;"><%=strTemp%></td>
<!--
      <td align="center" style="font-size:11px;"><%=WI.getStrValue(vSectionDetail.elementAt(i+4),"N/A")%><strong>/</strong><%=WI.getStrValue(vSectionDetail.elementAt(i+5),"N/A")%></td>
-->
      <td align="center" style="font-size:11px;"><%=(String)vSectionDetail.elementAt(i+6)%></td>
      <td align="center" style="font-size:11px;"><%=WI.getStrValue(vSectionDetail.elementAt(i+7),"0")%></td>
      <td align="center" style="font-size:11px;"><%=strStatus%></td>
      <td style="font-size:11px;"><div align="center"> <!-- do not show the radio button if it is a conflict -->
      <%
	  	if(!bolConflict[0]){if(!strStatus.startsWith("Closed") && !bolForDissolve){%>
	      <input type="radio" name="radiobutton" value="radiobutton" onClick='AssignSecIndex("<%=(String)vSectionDetail.elementAt(i+1)%>","<%=WI.getStrValue((String)vSectionDetail.elementAt(i+2))%>", "<%=i%>")'>
       <%}}else{
	   //System.out.println(vSectionDetail.elementAt(i+1));
	   //iIndexOf = advising.vConflictSubList.indexOf((String)vSectionDetail.elementAt(i+1));
	   //if(iIndexOf > -1)
	   	if(advising.vConflictSubList.size() > 1)
		strConflictSub = "<br><font style='color:red;font-weight:bold; font-size:14px;'>("+advising.vConflictSubList.elementAt(1)+")</font>";
	   else	
	   	strConflictSub = "&nbsp;";
		
	   %>
	      Conflict<%=strConflictSub%>
		<%
		bolConflict[0] = false;}%>

	    </div></td>
    </tr>
<%	i = i+7;}%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <td width="12%"></tr>
    <tr bgcolor="#FFFFFF">
      <td width="84%">&nbsp;</td>
      <td width="16%" height="25">
	  <a href="javascript:copyValueToParent();"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a>
	  </td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="sub_sec_index" value="0">
  <input type="hidden" name="sec_name_value" value="0">
  <input type="hidden" name="row_clicked" value="0">

  <input type="hidden" name="form_name" value="<%=request.getParameter("form_name")%>">
  <input type="hidden" name="sec_name" value="<%=request.getParameter("sec_name")%>">
  <input type="hidden" name="sec_index_name" value="<%=request.getParameter("sec_index_name")%>">
  <input type="hidden" name="sec_index_list" value="<%=request.getParameter("sec_index_list")%>">

  <!-- added on Sept 17 to take care of the subject with sub_subject offereing like caregiver -->
  <input type="hidden" name="course_index" value="<%=WI.fillTextValue("course_index")%>">
  <input type="hidden" name="major_index" value="<%=WI.fillTextValue("major_index")%>">
  <input type="hidden" name="year_level" value="<%=WI.fillTextValue("year_level")%>">
  <input type="hidden" name="sub_index" value="<%=WI.fillTextValue("sub_index")%>">
  <input type="hidden" name="degree_type" value="<%=WI.fillTextValue("degree_type")%>">
  
  <input type="hidden" name="index_of_" value="<%=WI.fillTextValue("index_of_")%>">
  <input type="hidden" name="line_number" value="<%=WI.fillTextValue("line_number")%>">
  <input type="hidden" name="add_oc" value="<%=WI.fillTextValue("add_oc")%>"><!-- add from other course -->

 
	<input type="hidden" name="syf" value="<%=WI.fillTextValue("syf")%>">
	<input type="hidden" name="syt" value="<%=WI.fillTextValue("syt")%>">
	<input type="hidden" name="semester" value="<%=WI.fillTextValue("semester")%>">
	
	
  <input type="hidden" name="cur_index" value="<%=WI.fillTextValue("cur_index")%>">
  <input type="hidden" name="sec_startsWith" value="<%=WI.fillTextValue("sec_startsWith")%>">

</form>
</body>
</html>
<%//System.out.println("Total Time : "+( new java.util.Date().getTime() - lTime));
dbOP.cleanUP();
//System.out.println( (lT - new java.util.Date().getTime())/100);
%>

