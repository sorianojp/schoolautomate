<%@ page language="java" import="utility.*,search.SearchStudent,enrollment.Authentication, java.util.Vector" %>
<%
boolean bolIsSchool = false;
if((new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<!-------- to make opacity -------->
<style type="text/css">
#im {
FILTER: alpha(opacity=50)
}
</style>

<script language="JavaScript" src="../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript">
/**
*	Added for opacity. Testing .
*/
function high(which2) {
	theobject=which2;
	highlighting=setInterval("highlightit(theobject)",50);
}
function low(which2) {
	clearInterval(highlighting);
	which2.filters.alpha.opacity=50;
}
function highlightit(cur2) {
	if(cur2.filters.alpha.opacity<100)
		cur2.filters.alpha.opacity+=5
	else if(window.highlighting)
		clearInterval(highlighting)
}
/************ end of opacity *****************/

function PrintPg() {
	document.search_util.print_pg.value = "1";
	this.SubmitOnce("search_util");	
}
function ReloadPage()
{
	document.search_util.searchStudent.value = "";
	document.search_util.print_pg.value = "";
	this.SubmitOnce("search_util");
}
function SearchStudent()
{
	document.search_util.searchStudent.value = "1";
	document.search_util.print_pg.value = "";
	this.SubmitOnce("search_util");
}
function PageAction(strPageAction, strIDNumber, strBarcode, bolReload) {
	document.search_util.page_action.value = strPageAction;
	document.search_util.print_pg.value = "";
	//this.SubmitOnce("search_util");
	if(strIDNumber.length > 0) {
		document.search_util.id_number2.value = strIDNumber;
		document.search_util.bar_code2.value = strBarcode;		
	}
	if(bolReload)
		this.SubmitOnce("search_util");
}
function UploadRF() {
	var pgLoc = "./barcode_mgmt_upload.jsp";
	var win=window.open(pgLoc,"PrintWindow",'width=550,height=750,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AjaxMapName(strRef, e) {
	if(e.keyCode == 13) {
		document.search_util.bar_code2.focus();
		return;
	}
		var strSearchCon = "";//"&search_temp=2";
		if(document.search_util.ajax_search_type1[1].checked)
			strSearchCon = "&is_faculty=1";
		
		var strCompleteName = document.search_util.id_number2.value;
		if(strCompleteName.length  < 3) 
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2"+strSearchCon+"&name_format=5&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
		//document.getElementById("coa_info").innerHTML=this.strPrevEntry+this.bolReturnStrEmpty
}
function UpdateID(strID, strUserIndex) {
	//do nothing.
	document.search_util.id_number2.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>

<body bgcolor="#D2AE72" onLoad="document.search_util.id_number2.focus();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./barcode_mgmt_print.jsp" />
	<%	return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-user admin->Bar code management.","barcode_mgmt.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														null);
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"System Administration","User Management",request.getRemoteAddr(),
					null);
}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"eSecurity Check","STUDENTS CAMPUS ATTENDANCE QUERY",request.getRemoteAddr(),
					null);
}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"System Administration","ASSIGN RFID",request.getRemoteAddr(),
					null);
}
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
					"Registrar Management","ASSIGN RFID",request.getRemoteAddr(),
					null);
}
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



strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	Authentication auth = new Authentication();
	if(auth.operateOnBarCode(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = auth.getErrMsg();
	else	
		strErrMsg = "RFID information updated successfully.";
}



String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"ID Number","Lastname","Firstname"};
String[] astrSortByVal     = {"id_number","lname","fname"};

int iSearchResult = 0;

SearchStudent searchStud = new SearchStudent(request);
if(WI.fillTextValue("searchStudent").compareTo("1") == 0){
	vRetResult = searchStud.searchBarcode(dbOP);
	if(vRetResult == null)
		strErrMsg = searchStud.getErrMsg();
	else	
		iSearchResult = searchStud.getSearchCount();
}

%>
<form action="./barcode_mgmt.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          RF ID MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">ID Number</td>
      <td colspan="2"><input type="text" name="id_number2" value="<%=WI.fillTextValue("id_number2")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1', event);">
	  <label id="coa_info" style="font-size:11px; font-weight:bold; color:#0000FF; position:absolute; width:400px;"></label>
	  </td>
      <td colspan="2" style="font-weight:bold; color:#0000FF; font-size:11px;">&nbsp;
	    <%if(strSchCode.startsWith("UL") && false){%>
	  	<a href="javascript:UploadRF();">Go to Batch Upload</a>
	    <%}%>	  
<%
strTemp = WI.fillTextValue("ajax_search_type1");
if(strTemp.length() == 0 || strTemp.equals("0")) 
	strTemp = " checked";
else
	strTemp = "";
	
%>		
		<input type="radio" name="ajax_search_type1" value="0" <%=strTemp%> tabindex="-1"> Search Student
<%if(strTemp.length() == 0) 
	strTemp = " checked";
else	
	strTemp= "";
%>
		<input type="radio" name="ajax_search_type1" value="1" <%=strTemp%> tabindex="-1"> Search Employee
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">RF ID </td>
      <td colspan="2"><input type="text" name="bar_code2" value="<%=WI.fillTextValue("bar_code2")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td colspan="2">
<%if(iAccessLevel > 1){%>
        <a href="javascript:PageAction('2','','',true);">
		<img src="../../images/update.gif" border="0" id="im" onMouseOver="high(this);" onMouseOut="low(this);"></a><font size="1">click 
        to record rfid information </font> <a href="#">
		<img src="../../images/clear.gif" border="0" id="im" onMouseOver="high(this);" onMouseOut="low(this);"
		 onClick="document.search_util.id_number2.value='';document.search_util.bar_code2.value=''"></a> <font size="1">click to clear</font>
<%}%>      </td>
    </tr>
<%if(strSchCode.startsWith("HAU")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td class="thinborderNONE">Valid Until </td>
      <td colspan="2">
	  		<input name="valid_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("valid_to")%>" class="textbox"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      		<a href="javascript:show_calendar('search_util.valid_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>		</td>
      <td colspan="2">&nbsp;</td>
    </tr>
<%}%>
    <tr bgcolor="#bbccFF">
      <td height="12" colspan="6" class="thinborderALL" align="center"><font size="2" color="#FF0000"><b>SEARCH</b></font></td>
    </tr>
    <tr>
      <td height="25" class="thinborderLEFT">&nbsp;</td>
      <td colspan="4">&nbsp;
<%
strTemp = WI.fillTextValue("show_barcode");
if(strTemp.equals("1"))
	strTemp = " checked";
else	
	strTemp = "";
%>	  
	  <input name="show_barcode" type="checkbox" value="1"<%=strTemp%>>
	  <font color="#0000FF"><b>Show Result without rfid information</b></font></td>
      <td class="thinborderRIGHT">
<%
strTemp = WI.fillTextValue("search_param");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strTemp = " checked";
else	
	strTemp = "";
if(bolIsSchool){%>	  
	<input name="search_param" type="radio" value="0"<%=strTemp%>>Search Student &nbsp;&nbsp;&nbsp;
<%}
else	
	strTemp = "";

if(strTemp.length() == 0)
	strTemp = " checked";
else	
	strTemp = "";
%>      <input name="search_param" type="radio" value="1"<%=strTemp%>>Search Employee </td>
    </tr>
    <tr> 
      <td width="3%" height="25" class="thinborderLEFT">&nbsp;</td>
      <td class="thinborderNONE">RF ID </td>
      <td><select name="barcode_id_con" style="font-size:11px">
          <%=searchStud.constructGenericDropList(WI.fillTextValue("barcode_id_con"),astrDropListEqual,astrDropListValEqual)%>
        </select></td>
      <td width="26%"><input type="text" name="barcode_id" value="<%=WI.fillTextValue("barcode_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td width="8%"><!--SY-SEM--></td>
      <td width="42%" class="thinborderRIGHT">&nbsp;
	  
	  <%if(strSchCode.startsWith("CIT")) {%>
	  	Show Student: 
		<select name="search_basic">
		<option value=""></option>
<%strTemp = WI.fillTextValue("search_basic");
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="1" <%=strErrMsg%>>Basic only</option>
<%if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="2" <%=strErrMsg%>>College only</option>
		</select>
	  
	  <input name="sy_from" type="text" size="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" maxlength=4>
-
<select name="semester">
  <%
strTemp = WI.fillTextValue("semester");
if(strTemp.compareTo("1") ==0){%>
  <option value="1" selected>1st Sem</option>
  <%}else{%>
  <option value="1">1st Sem</option>
  <%}if(strTemp.compareTo("2") ==0){%>
  <option value="2" selected>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") ==0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}%>
</select>
<%}//show only for CIT.. %>	  </td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;</td>
      <td class="thinborderNONE">ID </td>
      <td><select name="id_number_con" style="font-size:11px">
        <%=searchStud.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%>
      </select></td>
      <td><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td class="thinborderNONE">Firstname</td>
      <td class="thinborderRIGHT"><select name="fname_con" style="font-size:11px">
        <%=searchStud.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%>
      </select>
        <input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="25" class="thinborderLEFT">&nbsp;</td>
      <td class="thinborderNONE">Lastname</td>
      <td><select name="lname_con" style="font-size:11px">
        <%=searchStud.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%>
      </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td class="thinborderNONE">Date Assigned </td>
      <td class="thinborderRIGHT">
		<input name="assign_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("assign_date")%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		<a href="javascript:show_calendar('search_util.assign_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../images/calendar_new.gif" border="0"></a>
      </td>
    </tr>
<!--    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="4"><select name="course_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%//=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
 			//							" order by course_name asc", request.getParameter("course_index"), false)%> 
        </select></td>
    </tr>
-->    
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="3%" height="25" class="thinborderLEFT">&nbsp;</td>
      <td width="8%" class="thinborderNONE">Sort by</td>
      <td width="27%">
	  <select name="sort_by1" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
      </select>
        <select name="sort_by1_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="28%"><select name="sort_by2" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by2_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
      <td width="34%" class="thinborderRIGHT"><select name="sort_by3" style="font-size:10px">
	 	<option value="">N/A</option>
          <%=searchStud.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
        <select name="sort_by3_con" style="font-size:10px">
          <option value="asc">Asc</option>
<%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Desc</option>
<%}else{%>
          <option value="desc">Desc</option>
<%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="18" class="thinborderLEFT">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td class="thinborderRIGHT">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM">&nbsp;</td>
      <td class="thinborderBOTTOM"><a href="javascript:SearchStudent();"><img src="../../images/form_proceed.gif" border="0"></a></td>
      <td class="thinborderBOTTOMRIGHT">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td align="right" style="font-size:11px;"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a> Print Report&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="66%" ><b> Total Result : <%=iSearchResult%> - Showing(<%=searchStud.getDisplayRange()%>)</b></td>
      <td> <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/searchStud.defSearchSize;
		if(iSearchResult % searchStud.defSearchSize > 0) ++iPageCount;

		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="SearchStudent();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>
<%
int iIncr = 7;
if(WI.fillTextValue("sy_from").length() > 0) 
	iIncr = 9;
%>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr align="center" style="font-weight:bold"> 
      <td  width="14%" height="25" ><font size="1">ID</font></td>
      <td width="17%"><font size="1">RF ID NUMBER </font></td>
      <td width="18%"><font size="1">LASTNAME</font></td>
      <td width="18%"><font size="1">FIRSTNAME</font></td>
      <td width="13%"><font size="1">MIDDLE NAME </font></td>
<%if(iIncr == 9) {%>
	      <td width="13%"><font size="1">COURSE - YR</font></td>
<%}%>
      <td width="13%"><font size="1">ASSIGNED DATE</font></td>
      <td width="9%"><font size="1">EDIT</font></td>
      <td width="11%"><font size="1">REMOVE</font></td>
    </tr>
<%
Vector vGLevelInfo = new Vector();
strTemp = "select g_level, level_name from bed_level_info";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
while(rs.next()) {
	vGLevelInfo.addElement(rs.getString(1));
	vGLevelInfo.addElement(rs.getString(2));
}	
rs.close();

	
for(int i=0; i<vRetResult.size(); i+=iIncr){%>
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+2))%></td>
      <td>&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"xxxxxx")%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td>&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
      <td>&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+5))%></td>
<%if(iIncr == 9){
	strTemp = (String)vRetResult.elementAt(i + 6);
	if(strTemp == null) //basic
		strTemp = (String)vGLevelInfo.elementAt(vGLevelInfo.indexOf(vRetResult.elementAt(i + 7)) + 1);
	else	
		strTemp = strTemp + WI.getStrValue((String)vRetResult.elementAt(i + 7),"-","","");
	%>
	      <td><%=strTemp%></td>
<%}
if(iIncr == 9)
	strTemp = (String)vRetResult.elementAt(i + 8);
else	
	strTemp = (String)vRetResult.elementAt(i + 6);
%>
      <td><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <td align="center">&nbsp;
<%if(iAccessLevel > 1) {%>
	  <a href='javascript:PageAction("","<%=(String)vRetResult.elementAt(i+2)%>","<%=WI.getStrValue(vRetResult.elementAt(i+1))%>",false);'><img src="../../images/edit.gif" border="0"></a>
<%}%>	  </td>
      <td align="center">&nbsp;
<%if(iAccessLevel == 2) {%>
	  <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i+2)%>","",true);'><img src="../../images/delete.gif" border="0"></a>
<%}%>	  </td>
    </tr>
<%}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25"><div align="right"> </div></td>
      <td width="31%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td><div align="right"></div></td>
    </tr>
  </table>
<%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="searchStudent" value="<%=WI.fillTextValue("searchStudent")%>">
<input type="hidden" name="print_pg">

<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>