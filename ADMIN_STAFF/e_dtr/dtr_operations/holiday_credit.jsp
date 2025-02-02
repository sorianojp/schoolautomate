<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR,eDTR.eDTRUtil,
																eDTR.Holidays" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Holiday Override Rate</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<style  type="text/css">
TD{
	font-size:11px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
</style>
</head>

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--

function CancelRecord(){
	location = "./holiday_credit.jsp";
}
///ajax here to load dept..
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.dtr_op.c_index[document.dtr_op.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

	function ReloadPage(){
		document.dtr_op.submit();
	}

	function ViewRecords(){
		document.dtr_op.reset_values.value = '1';	
		document.dtr_op.print_page.value = "";
		document.dtr_op.viewAll.value=1;
		document.dtr_op.submit();
	}

	function goToNextSearchPage()
	{
		document.dtr_op.viewAll.value=1;
		document.dtr_op.delete_records.value = "0";
		document.dtr_op.submit();
	}
	 
	function printpage(){
		document.dtr_op.print_page.value = "1";
		document.dtr_op.delete_records.value = "0";		
		document.dtr_op.submit();
	}

//all about ajax - to display student list with same name.
		var objCOA;
		var objCOAInput;
function AjaxMapName(strFieldName, strLabelID) {
		objCOA=document.getElementById(strLabelID);
		var strCompleteName = eval("document.dtr_op."+strFieldName+".value");
		eval('objCOAInput=document.dtr_op.'+strFieldName);
		if(strCompleteName.length <=2) {
			objCOA.innerHTML = "";
			return ;
		}		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}

		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
		"&name_format=4&complete_name="+escape(strCompleteName);
		this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	objCOAInput.value = strID;
	objCOA.innerHTML = "";
	//document.dtr_op.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function checkAllSave() {
	var maxDisp = document.dtr_op.emp_count.value;
	//unselect if it is unchecked.
	if(!document.dtr_op.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.dtr_op.save_'+i+'.checked=true');
	}
}	

function SaveRequests(){
	document.dtr_op.page_action.value = "1";
	document.dtr_op.viewAll.value="1";
	document.dtr_op.submit();
}

function DeleteRecords(){
	document.dtr_op.page_action.value = "0";
	document.dtr_op.viewAll.value="1";
	document.dtr_op.submit();
}
function CopyDetails(strFieldName){
	var vItems = document.dtr_op.emp_count.value;
	if (vItems.length == 0)
		return;	

	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.dtr_op.'+strFieldName+i+'.value=document.dtr_op.'+strFieldName+'1.value');			

} 
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
if( request.getParameter("print_page") != null && request.getParameter("print_page").equals("1"))
{ //System.out.println("hellow1");%>
	<jsp:forward page="./view_all_ot_request_print.jsp" />
<%}
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;	
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");

	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasTeam = false;
	int i = 0;	

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record--OVERTIME MANAGEMENT-Overtime Request(Batch)","holiday_credit.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
int iAccessLevel = 	comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"eDaily Time Record","OVERTIME MANAGEMENT",
											request.getRemoteAddr(),"holiday_credit.jsp");	
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT-Request Overtime",request.getRemoteAddr(), 
														"holiday_credit.jsp");	
}
if(bolMyHome && iAccessLevel == 0) { 
	iAccessLevel = 1;	
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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=",">","<"};
if(bolIsSchool)
	strTemp = "College";
else
	strTemp = "Division";

String[] astrSortByName    = {"ID number", "First name", "Last Name","Department",strTemp};

String[] astrSortByVal     = {"id_number", "user_table.fname", "user_table.fname", 
															"d_name","c_name"};
int iSearchResult = 0;

Holidays hol = new Holidays();
Vector vRetResult = null;
boolean bolRetain = true;
strTemp = WI.fillTextValue("page_action");
 
if(strTemp.length() > 0){
 	vRetResult = hol.operateOnAutoCreditHoliday(dbOP, request, Integer.parseInt(strTemp));
	if(vRetResult == null)
		strErrMsg = hol.getErrMsg();
	else{
		bolRetain = false;		
		strErrMsg = WI.getStrValue(hol.getErrMsg(),"Operation Succesful<br>","","Select records to update");
	}
}

if (WI.fillTextValue("viewAll").equals("1")){
	vRetResult = hol.operateOnAutoCreditHoliday(dbOP, request, 4);
	if (vRetResult == null)
		strErrMsg =  hol.getErrMsg();
	else
		iSearchResult = hol.getSearchCount();
}
%>
<form action="./holiday_credit.jsp" method="post" name="dtr_op">
<input type="hidden" name="print_page">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
       AUTO CREDIT  FOR UNWORKED HOLIDAYS ::::</strong></font></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="28" colspan="5"><font size="2" color="#FF0000"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    
    <tr>
      <td height="24">&nbsp;</td>
      <td>Search Holiday Type</td>
			<%
				strTemp = WI.fillTextValue("holiday_type_search");
			%>
      <td colspan="3">
        <select name="holiday_type_search">
          
					<option value="">Select holiday type</option>
					
          <%=dbOP.loadCombo("holiday_type_index","type"," from edtr_holiday_type " +
								  					" where is_del = 0  order by TYPE asc", strTemp, false)%>
        </select>
				<font size="1">select holiday type to filter search result</font>			</td>
    </tr>
    <tr>
      <td width="3%" height="24">&nbsp;</td>
      <td width="16%">Status</td>
      <td width="81%" colspan="3"><select name="pt_ft" onChange="ReloadPage();">
        <option value="">All</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part-time</option>
        <%}else{%>
        <option value="0">Part-time</option>
        <%}if (WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="1" selected>Full-time</option>
        <%}else{%>
        <option value="1">Full-time</option>
        <%}%>
      </select></td>
    </tr>
 
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> <select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3">
			<label id="load_dept">
	  	<select name="d_index">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
      </select>	  
			</label></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td colspan="3"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)			</td>
    </tr>
 		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>      </td>
    </tr>
		<%}%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10" colspan="3"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('emp_id', 'coa_info');">
      <strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></strong>
			<label id="coa_info"></label>			</td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10" colspan="5">OPTION:</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">
			<%
				strTemp = WI.fillTextValue("with_schedule");
				strTemp = WI.getStrValue(strTemp,"1");
				if(strTemp.compareTo("1") == 0) 
					strTemp = " checked";
				else	
					strTemp = "";	
			%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
View with auto credit only
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View all Employees</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">
			<%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ViewRecords();">View ALL </td>
    </tr>		
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td width="29%" height="29"><select name="sort_by1">
        <option value="">N/A</option>
        <%=hol.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td width="29%" height="29"><select name="sort_by2">
        <option value="">N/A</option>
        <%=hol.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td width="29%" height="29"><select name="sort_by3">
        <option value="">N/A</option>
        <%=hol.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>

    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="10%" height="15">&nbsp;</td>
      <td><select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by2_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
      <td><select name="sort_by3_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ViewRecords();">
      <font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>
<% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="48%" height="10">&nbsp;</td>
      <td width="52%" height="10" colspan="2" align="right">
		<%
		if(WI.fillTextValue("view_all").length() == 0){
		int iPageCount = iSearchResult/hol.defSearchSize;
		if(iSearchResult % hol.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%>
Jump To page:
  <select name="jumpto" onChange="ViewRecords();">
    <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
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
  <%}
	}%>
	</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
       <td height="20" colspan="6" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="5%" class="thinborder">&nbsp;</td> 
      <td width="25%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="25%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
			<%if(WI.fillTextValue("with_schedule").equals("1")){%>
			<td width="17%" align="center" class="thinborder"><strong><font size="1">HOLIDAY TYPE</font></strong></td>
			<%}%>
			<td width="8%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br></strong>
        <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();">
      </font></td>
    </tr>
    
    <% 	int iCount = 1;
	   for (i = 0; i < vRetResult.size(); i+=13,iCount++){
		 %>
    <tr>
      <td class="thinborder">&nbsp;<%=iCount%></td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
			<input type="hidden" name="emp_id_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">
			<input type="hidden" name="override_index_<%=iCount%>" value="<%=vRetResult.elementAt(i+7)%>">
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>							
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%> </td>
			<%
			if(WI.fillTextValue("with_schedule").equals("1")){
				strTemp = (String)vRetResult.elementAt(i+8);
			%>
			<td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp)%></td>
			<%}%>
			<%
			strTemp = WI.fillTextValue("save_"+iCount);
			if(strTemp.length() > 0 && bolRetain)
				strTemp = " checked";
			else
				strTemp = "";
			%>
      <td align="center" class="thinborder">
			<input type="checkbox" name="save_<%=iCount%>" value="1" tabindex="-1" <%=strTemp%>>
			</td>
    </tr>
    <%} //end for loop%>
		 <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
	<%if(!WI.fillTextValue("with_schedule").equals("1")){%>
	<table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
			<tr> 
				<td height="22" colspan="2">Note: Employees having auto credit will be paid on holidays even if he/she did not work. </td>
			</tr>
			<tr>
			  <td width="25%" align="right">Holiday Type : </td>
				<%
					strTemp =  WI.fillTextValue("holiday_type");
				%>
	      <td width="75%">
					<select name="holiday_type">
          <%=dbOP.loadCombo("holiday_type_index","type"," from edtr_holiday_type " +
								  					" where is_del = 0  order by TYPE asc",strTemp, false)%>
          </select>
				</td>
		</tr>
	</table>	
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="7" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="7" align="center"><%if((WI.fillTextValue("with_schedule")).equals("1")){
					if(iAccessLevel == 2){%>
				<input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecords();">
				<font size="1">Click to delete selected </font>
				<%}
				}else{
					if(iAccessLevel > 1){%>				
        <input type="button" name="122" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveRequests();">
        <font size="1">click to save entries</font>			  
        <%}
				}%>
        <input type="button" name="1223" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:CancelRecord();">
        <font size="1"> click to cancel or go previous</font>	</td>
    </tr>   
  </table>
 <% } // end vRetResult != null && vRetResult.size() > 0 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td width="100%" height="25">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="reset_values">
	<input type="hidden" name="viewAll" value="">
	<input type="hidden" name="copy_all" value="">	
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>