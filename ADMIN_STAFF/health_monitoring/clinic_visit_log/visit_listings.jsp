<%@ page language="java" import="utility.*, health.ClinicVisitLog ,java.util.Vector " %>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsAUF = strSchCode.startsWith("AUF");
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript">
<!--
function ViewDetails(strInfoIndex, strID)
{
	var pgLoc = "./case_detail.jsp?info_index="+strInfoIndex+"&visit_index="+strInfoIndex+"&stud_id="+strID;
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ReloadPage()
{
	return this.StartSearch();
}
function StartSearch()
{
	document.form_.executeSearch.value = "1";
	this.SubmitOnce('form_');
}
///ajax here to load major..
function loadDept() {
	var objCOA=document.getElementById("load_dept");
	var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	///if blur, i must find one result only,, if there is no result foud
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
	//alert(strURL);
	this.processRequest(strURL);
}
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;

	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	int iSearchResult = 0;
	String[] astrSortByName    = {"Visit Date","Case #","Patient ID","FirstName","LastName","Doctor ID"};
	String[] astrSortByVal     = {"visit_date","case_no","patient_table.id_number","patient_table.fname","patient_table.lname", "doc_table.id_number"};
	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","visit_listings.jsp");
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
														"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
														"visit_listings.jsp");
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

	ClinicVisitLog CVLog = new ClinicVisitLog();
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};

	String[] astrList = {"Starts with","Ends with","Contains"};
	String[] astrListVal = {"starts","ends","contains"};
	String strSlash = "";
	
	Vector vEmployeeCollegeDept = null;
	
	if (WI.fillTextValue("executeSearch").compareTo("1")==0){
	vRetResult = CVLog.viewListings(dbOP, request);
	if(vRetResult == null)
		strErrMsg = CVLog.getErrMsg();
	else
		iSearchResult = CVLog.getSearchCount();
	
	if (strErrMsg == null)
		strErrMsg = CVLog.getErrMsg();
	}
	
	if(!bolIsSchool && vRetResult != null)
		vEmployeeCollegeDept = CVLog.getEmployeeCollegeDept(dbOP);
	if(vEmployeeCollegeDept == null)
		vEmployeeCollegeDept = new Vector();
		
	int iIndexOf = 0;
%>
<body bgcolor="#8C9AAA" class="bgDynamic">
<form action="./visit_listings.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td width="61%" height="28" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CLINIC VISIT LOG - LISTINGS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="18" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(bolIsSchool) {%>
	<tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Patient option </td>
      <td bgcolor="#FFFFFF">
			<select name="user_type">
        <option value="">Show All</option>
        <% if(WI.fillTextValue("user_type").equals("0")){%>
        <option value="0" selected>Show only Employees</option>
        <%}else{%>
        <option value="0">Show only Employees</option>
        <%}%>
		<%if(bolIsSchool){
			if(WI.fillTextValue("user_type").equals("1")){%>
        		<option value="1" selected>Show only students</option>
        	<%}else{%>
        		<option value="1">Show only students</option>
        	<%}
		}%>		
      </select></td>
    </tr>
<%}//show all for company.. %>
    <tr bgcolor="#697A8F"> 
      <td width="3%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="17%" bgcolor="#FFFFFF">Attended by(ID)</td>
			<%strTemp = WI.fillTextValue("doc_id");%>
      <td width="80%" bgcolor="#FFFFFF"><strong>         
        <select name="doc_id_con">
          <%=CVLog.constructGenericDropList(WI.fillTextValue("doc_id_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
        <input name="doc_id" type="text" size="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"> 
      Doctor</strong></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Attended by(ID)</td>
			<%strTemp = WI.fillTextValue("nurse_id");%>
      <td bgcolor="#FFFFFF"><strong>
        <select name="nurse_id_con">
          <%=CVLog.constructGenericDropList(WI.fillTextValue("nurse_id_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
        <input name="nurse_id" type="text" size="16" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>">
      Nurse</strong></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Visit By(ID) :</td>
      <%strTemp = WI.fillTextValue("patient_id");%>
			<td bgcolor="#FFFFFF"><strong>
        <select name="patient_id_con">
          <%=CVLog.constructGenericDropList(WI.fillTextValue("patient_id_con"),astrDropListEqual,astrDropListValEqual)%>
        </select>
        <input name="patient_id" type="text" size="16" class="textbox" 
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>">
      </strong></td>
    </tr>
<%if(!bolIsSchool){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td height="25"><select name="c_index" onChange="loadDept();">
          <option value="0">N/A</option>
<%
strTemp = WI.fillTextValue("c_index");

if(strTemp.length() == 0) {
	strTemp = "0";
	strTemp2 = "Offices";
}
else
	strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%>
        </select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><%=strTemp2%></td>
      <td height="25">
<label id="load_dept">
	  <select name="d_index">
          <option value="">All</option>
<%
strTemp3 = WI.fillTextValue("d_index");

if(strTemp.equals("0"))
	strTemp = " (c_index is null or c_index = 0) ";
else	
 	strTemp = " c_index = "+strTemp;
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and "+strTemp+" order by d_name asc",strTemp3, false)%>
        </select>
</label>      </td>
    </tr>
<%}//do not show if school%>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Purpose of visit </td>
      <td bgcolor="#FFFFFF">
				<%strTemp = WI.fillTextValue("purpose");%>
        <select name="purpose">
          <option value="">Select purpose of visit</option>
          <%=dbOP.loadCombo("purpose_index","purpose"," FROM hm_preload_purpose order by purpose", strTemp, false)%>
        </select>      </td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Complaints</td>
      <td bgcolor="#FFFFFF"><strong> 
        <%strTemp = WI.fillTextValue("comp1_index");%>
        <select name="comp1_index">
          <option value="">Select Complaint</option>
			<%=dbOP.loadCombo("COMPLAINT_TYPE_INDEX","COMPLAINT_TYPE"," FROM HM_PRELOAD_COMPLAINT", strTemp, false)%>
        </select>
         or&nbsp; 
         <%strTemp = WI.fillTextValue("comp2_index");%>
        <select name="comp2_index">
          <option value="">Select Complaint</option>
			<%=dbOP.loadCombo("COMPLAINT_TYPE_INDEX","COMPLAINT_TYPE"," FROM HM_PRELOAD_COMPLAINT", strTemp, false)%>
        </select>
        &nbsp; or &nbsp; 
        <%strTemp = WI.fillTextValue("comp3_index");%>
        <select name="comp3_index">
          <option value="">Select Complaint</option>
			<%=dbOP.loadCombo("COMPLAINT_TYPE_INDEX","COMPLAINT_TYPE"," FROM HM_PRELOAD_COMPLAINT", strTemp, false)%>
        </select>
        </strong></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Diagnosis</td>
      <td bgcolor="#FFFFFF">
			<select name="diagnosis_con">
        <%=CVLog.constructGenericDropList(WI.fillTextValue("diagnosis_con"),astrList,astrListVal)%>
      </select>
      <input type="text" name="diagnosis" value="<%=WI.fillTextValue("diagnosis")%>" class="textbox"
	 	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Prognosis</td>
      <td bgcolor="#FFFFFF"><strong> 
        <%strTemp = WI.fillTextValue("prog1_index");%>
       <select name="prog1_index">
          <option value="">Select Prognosis</option>
			<%=dbOP.loadCombo("PROGNOSIS_TYPE_INDEX","PROGNOSIS_TYPE"," FROM HM_PRELOAD_PROGNOSIS", strTemp, false)%>
        </select>
         or&nbsp; 
         <%strTemp = WI.fillTextValue("prog2_index");%>
       <select name="prog2_index">
          <option value="">Select Prognosis</option>
			<%=dbOP.loadCombo("PROGNOSIS_TYPE_INDEX","PROGNOSIS_TYPE"," FROM HM_PRELOAD_PROGNOSIS", strTemp, false)%>
        </select>
        &nbsp; or  
         <%strTemp = WI.fillTextValue("prog3_index");%>
       <select name="prog3_index">
          <option value="">Select Prognosis</option>
			<%=dbOP.loadCombo("PROGNOSIS_TYPE_INDEX","PROGNOSIS_TYPE"," FROM HM_PRELOAD_PROGNOSIS", strTemp, false)%>
        </select>
        </strong></td>
    </tr>
<%if(bolIsAUF){%>
	<tr>
		<td height="25">&nbsp;</td>
	    <td>Accr. Physician: </td>
	    <td>
			<%
				strTemp = WI.fillTextValue("accr_physician");
			%>
			<select name="accr_physician">
				<option value="">Select Accr. Physician</option>
				<%=dbOP.loadCombo("physician_index","physician_name", " from hm_accredited_physicians where is_valid = 1 order by physician_name",strTemp,false)%>
			</select></td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
	    <td>Ref. Physician: </td>
	    <td>
			<%
				strTemp = WI.fillTextValue("ref_physician");
			%>
			<select name="ref_physician">
				<option value="">Select Ref. Physician</option>
				<%=dbOP.loadCombo("physician_index","physician_name", " from hm_accredited_physicians where is_valid = 1 order by physician_name",strTemp,false)%>
			</select></td>
	</tr>
<%}%>
    <tr bgcolor="#697A8F"> 
      <td height="18" colspan="3" bgcolor="#FFFFFF"><hr size="1"></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Date Range</td>
      <td bgcolor="#FFFFFF"> 
      <%strTemp = WI.fillTextValue("date_fr");%>
        <input name="date_fr" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
         &nbsp; &nbsp; <strong>to</strong> &nbsp; &nbsp; 
	  <%strTemp = WI.fillTextValue("date_to");%>
        <input name="date_to" type="text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>        </td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="21" colspan="3" bgcolor="#FFFFFF"><hr size="1"></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF">SORT BY</td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF"><select name="sort_by1">
			<option value="">N/A</option>
				<%=CVLog.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
			</select>&nbsp;&nbsp;
			<select name="sort_by1_con">
				<option value="asc">Ascending</option>
			<%if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by2">
			<option value="">N/A</option>
	          <%=CVLog.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
			</select>
			<select name="sort_by2_con">
					<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="43" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF"><a href="javascript:StartSearch();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
 <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" bgcolor="#FFFFFF" class="thinborder" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFF9F"> 
      <td height="25" colspan="7" align="center" class="thinborder"><font size="2"><strong>RESULT 
          OF SPECIFICATION(S)</strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">TOTAL 
        :<strong><%=iSearchResult%></strong></font></td>
      <td colspan="3" class="thinborder">  <div align="right"><font size="1"> 
          <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/CVLog.defSearchSize;
		if(iSearchResult % CVLog.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
          Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}}%>
          </select>
          <%} else {%>
          &nbsp; 
          <%}%></font>
          </div></td>
    </tr>
    <tr> 
      <td width="15%" height="25" align="center" class="thinborder"><font size="1"><strong>Date</strong></font></td>
      <td width="16%" align="center" class="thinborder"><font size="1"><strong>Case # </strong></font></td>
      <td width="16%" align="center" class="thinborder"><font size="1"><strong>ID Number </strong></font></td>
<%if(!bolIsSchool) {%>
      <td width="16%" align="center" class="thinborder"><font size="1"><strong>Division/Dept</strong></font></td>
<%}%>
      <td width="23%" align="center" class="thinborder"><font size="1"><strong>Name</strong></font></td>
      <td width="23%" align="center" class="thinborder"><font size="1"><strong>Attended By </strong></font></td>
      <td width="7%" class="thinborder">&nbsp;</td>
    </tr>
    <%for(int i =0; i<vRetResult.size(); i+=17){%>
    <tr> 
      <td height="25" class="thinborder"><%=WI.formatDate((String)vRetResult.elementAt(i+1),1)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+10)%></td>
<%if(!bolIsSchool) {
	iIndexOf = vEmployeeCollegeDept.indexOf(vRetResult.elementAt(i+10));
	if(iIndexOf > -1) {
		strTemp = (String)vEmployeeCollegeDept.elementAt(iIndexOf + 3);
		vEmployeeCollegeDept.remove(iIndexOf);vEmployeeCollegeDept.remove(iIndexOf);
		vEmployeeCollegeDept.remove(iIndexOf);vEmployeeCollegeDept.remove(iIndexOf);
	}
	else	
		strTemp = null;
	%>
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp")%></td>
<%}%>
      <td class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+7), (String)vRetResult.elementAt(i+8), (String)vRetResult.elementAt(i+9),7)%></td>
			<%
				strTemp = WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5),7);
				strTemp = WI.getStrValue(strTemp,"(" + (String)vRetResult.elementAt(i+6) + ")&nbsp;","","");
				strTemp2 = WI.formatName((String)vRetResult.elementAt(i+13), (String)vRetResult.elementAt(i+14), (String)vRetResult.elementAt(i+15),7);
				strTemp2 = WI.getStrValue(strTemp2,"(" + (String)vRetResult.elementAt(i+16) + ")&nbsp;","","");				
				
				if(strTemp.length() > 0 && strTemp2.length() > 0)
					strSlash = " / ";
				else
					strSlash = "";
			%>
      <td class="thinborder">&nbsp;<%=strTemp%><%=strSlash%><%=strTemp2%></td>
      <td class="thinborder"><div align="center"><a href='javascript:ViewDetails(<%=((String)vRetResult.elementAt(i))%>, "<%=((String)vRetResult.elementAt(i+10))%>")'> 
          <img src="../../../images/view.gif" width="40" height="31" border="0"></a></div></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr>
      <td height="10" colspan="9">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
