<%@ page language="java" import="utility.*, health.HMReports ,java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

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
function ReloadPage()
{
	document.form_.print_page.value= "";
	document.form_.submit();
}
function StartSearch()
{
	document.form_.executeSearch.value = "1";
	document.form_.print_page.value= "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
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
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
 
	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	int iSearchResult = 0;
	String[] astrSortByName = {"Visit Date", "ID Number", "Last Name", "FirstName", "Diagnosis", "Purpose of visit"};
	String[] astrSortByVal  = {"visit_date", "id_number", "lname", "fname", "diagnosis", "purpose"};
	
	if (WI.fillTextValue("print_page").length() > 0){ %>
		<jsp:forward page="./clinic_vlog_rpt_print.jsp"/>
	<% return;}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","clinic_vlog_rpt.jsp");
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
														"clinic_vlog_rpt.jsp");
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
  String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
	HMReports hmReports = new HMReports();
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};

	String[] astrList = {"Starts with","Ends with","Contains"};
	String[] astrListVal = {"starts","ends","contains"};
	
	if (WI.fillTextValue("executeSearch").compareTo("1")==0){
	vRetResult = hmReports.viewVisitLogs(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hmReports.getErrMsg();
	else
		iSearchResult = hmReports.getSearchCount();
 	if (strErrMsg == null)
		strErrMsg = hmReports.getErrMsg();
	}
%>
<body bgcolor="#8C9AAA" class="bgDynamic">
<form action="./clinic_vlog_rpt.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td width="61%" height="28" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        CLINIC VISIT LOG - LISTINGS PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="18" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(bolIsSchool){%>
	<tr bgcolor="#697A8F">
      <td width="3%" height="33" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="16%" bgcolor="#FFFFFF">Patient option </td>
      <td width="81%" bgcolor="#FFFFFF">
			<select name="user_type" onChange="document.form_.submit();">
        <option value="">Show All</option>
        <% if(WI.fillTextValue("user_type").equals("0")){%>
        <option value="0" selected>Show only Employees</option>
        <%}else{%>
        <option value="0">Show only Employees</option>
        <%}%>
        <% if(WI.fillTextValue("user_type").equals("1")){%>
        <option value="1" selected>Show only students</option>
        <%}else{%>
        <option value="1">Show only students</option>
        <%}%>				
      </select></td>
    </tr>
		<%if(WI.fillTextValue("user_type").equals("1")){%>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Year / Sem</td>
      <td bgcolor="#FFFFFF">
        <% strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
        <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
		onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%  strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
<input name="sy_to" type="text" size="4" maxlength="4" 
			  value="<%=strTemp%>" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
/
<select name="semester">
  <%
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
	 
	 
	 
	 
	 
<%}


if(WI.fillTextValue("user_type").length() > 0){%>
	<tr bgcolor="#697A8F">
      <td width="3%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="16%" bgcolor="#FFFFFF">Patient Category</td>
      <td width="81%" bgcolor="#FFFFFF">
        <select name="patient_category">
 			<%
			strTemp = WI.fillTextValue("patient_category");
			if(WI.fillTextValue("user_type").equals("1")){			
			if(strTemp.equals("1"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
 			<option value="1" <%=strErrMsg%>>Preschool</option>
			
			<%
			if(strTemp.equals("2"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
			<option value="2" <%=strErrMsg%>>Grade School</option>
			
			<%
			if(strTemp.equals("3"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
			<option value="3" <%=strErrMsg%>>High School</option>
			<%
			if(strTemp.equals("0"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
			<option value="0" <%=strErrMsg%>>College</option>
			
			<%}else{%>
			<%
			if(strTemp.equals("1"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
			<option value="1" <%=strErrMsg%>>Academic Personnel</option>
			
			<%
			if(strTemp.equals("0"))
				strErrMsg = "selected";
			else
				strErrMsg = "";
			%>
			<option value="0" <%=strErrMsg%>>Non - Academic Personnel</option>
			
			<%}%>
        </select>
      </td>
    </tr>

<%}//if(WI.fillTextValue("user_type").length() > 0)

}//show only if called from school.. 
else{%>
	<input type="hidden" name="user_type" value="0">
<%}%>
    <tr bgcolor="#697A8F">
      <td width="3%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="16%" bgcolor="#FFFFFF">Purpose of visit </td>
      <td width="81%" bgcolor="#FFFFFF"><strong>
        <%strTemp = WI.fillTextValue("purpose_index");%>
        <select name="purpose_index">
          <option value="">Select purpose of visit</option>
          <%=dbOP.loadCombo("purpose_index","purpose"," FROM hm_preload_purpose order by purpose", strTemp, false)%>
        </select>
      </strong></td>
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
      <td bgcolor="#FFFFFF"><select name="diagnosis_con">
        <%=hmReports.constructGenericDropList(WI.fillTextValue("diagnosis_con"),astrList,astrListVal)%>
      </select>
        <input type="text" name="diagnosis" value="<%=WI.fillTextValue("diagnosis")%>" class="textbox"
	 	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Last Name </td>
      <td bgcolor="#FFFFFF">
		<select name="last_name_con">
        <%=hmReports.constructGenericDropList(WI.fillTextValue("last_name_con"),astrList,astrListVal)%>
      </select>
	  <input name="last_name" type="text" value="<%=WI.fillTextValue("last_name")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">ID Number </td>
      <td bgcolor="#FFFFFF">
		<select name="id_con">
        <%=hmReports.constructGenericDropList(WI.fillTextValue("id_con"),astrList,astrListVal)%>
      </select>
		<input name="id_" type="text" value="<%=WI.fillTextValue("id_")%>" class="textbox" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
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
        </select>
	  </td>
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
</label>
      </td>
    </tr>
<%}//do not show if school%>
    <tr bgcolor="#697A8F">
      <td height="25" colspan="3" bgcolor="#FFFFFF"><hr size="1"></td>
    </tr>
    
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF">SORT BY</td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF"><select name="sort_by1">
			<option value="">N/A</option>
	          <%=hmReports.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
			</select>&nbsp;&nbsp;
			<select name="sort_by1_con">
				<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by2">
			<option value="">N/A</option>
	          <%=hmReports.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
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
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td align="right"><font size="2">Number of records per page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i =10; i <=45 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
			}%>
        </select>
        <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" class="thinborder" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFF9F"> 
      <td height="25" colspan="7" align="center" class="thinborder"><strong><font size="2">CLINIC VISIT LOG  SEARCH RESULT </font></strong></td>
    </tr>
    <tr>
      <td class="thinborder">&nbsp;</td> 
      <td height="25" class="thinborder"><font size="1" face="Verdana, Arial, Helvetica, sans-serif">TOTAL 
        :<strong><%=iSearchResult%></strong></font></td>
      <td colspan="5" class="thinborder">  <div align="right"><font size="1"> 
          <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/hmReports.defSearchSize;
		if(iSearchResult % hmReports.defSearchSize > 0) ++iPageCount;
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
      <td width="8%" align="center" class="thinborder">Date</td> 
      <td width="11%" height="25" align="center" class="thinborder">ID Number</td>
      <td width="26%" align="center" class="thinborder">Name</td>
      <td width="13%" align="center" class="thinborder">Dept/Office</td>
      <td width="13%" align="center" class="thinborder">Purpose of Visit</td>
      <td width="13%" align="center" class="thinborder">Complaints</td>
      <td width="16%" align="center" class="thinborder">Diagnosis</td>
    </tr>
    <%for(int i =0; i<vRetResult.size(); i+=12){%>
    <tr>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),4)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+9),(String)vRetResult.elementAt(i+10))%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+11),"&nbsp;")%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
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
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
