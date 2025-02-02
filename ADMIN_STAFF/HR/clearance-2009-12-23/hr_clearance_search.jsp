<%@ page language="java" import="utility.*,java.util.Vector,hr.HRClearance" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(6);
	//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Post Clearances</title>
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
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, 
					strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + 
	"&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond) + 
	"&extra_cond="+escape(strExtraCond) +
	"&max_len=256&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"viewList",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage() {
	document.form_.searchEmployee.value="";
	document.form_.print_page.value="";
	document.form_.submit();
}

function SearchEmployee(){	
	document.form_.searchEmployee.value="1";
	document.form_.print_page.value="";
	document.form_.submit();
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	var bolIsSelAll = document.form_.selAllSave.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function PrintPg() {
	document.form_.print_page.value = "1";
	document.form_.submit()
}

function DeleteRecord(){
	var vProceed = confirm('Remove selected records?');
	if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}	
}

function SaveData() {
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.save.disabled = true;
	document.form_.submit();
}

function CancelRecord(){
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	document.form_.submit()
}

function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

var objCOA;
var objCOAInput;

function AjaxMapName(strFieldName, strLabelID) {
	objCOA=document.getElementById(strLabelID);
	var strCompleteName = eval("document.form_."+strFieldName+".value");
	eval('objCOAInput=document.form_.'+strFieldName);
	if(strCompleteName.length <= 2) {
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

function CopyClearanceName()
{
	document.form_.clearance_name.value = document.form_.clearance_type[document.form_.clearance_type.selectedIndex].text;
}

</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./hr_clearance_search_print.jsp" />
	<% 
		return;}
		
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-CLEARANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		if(bolIsSchool)
			request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		else
			request.getSession(false).setAttribute("go_home","../../../index.jsp");
		
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthTypeIndex == null){
		request.getSession(false).setAttribute("go_home","../../../index.jsp");
		request.getSession(false).setAttribute("errorMessage","You are not logged in. Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR Management-Clearance-Search Clearance","hr_clearance_search.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}

	Vector vRetResult = null;
	Vector vEditInfo = null;
	HRClearance hrc = new HRClearance();
	int iSearchResult = 0;
	int i = 0;

	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
		
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};
		
	String strPageAction = WI.fillTextValue("page_action");
	if(strPageAction.length() > 0){
		if(hrc.OperateOnPostClearance(dbOP, request, Integer.parseInt(strPageAction)) == null){
			strErrMsg = hrc.getErrMsg();
		} else {
			if(strPageAction.equals("1"))
				strErrMsg = "Clearance successfully added";		
			if(strPageAction.equals("0"))
				strErrMsg = "Clearance successfully removed.";	
		}
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	    vRetResult = hrc.OperateOnSearchClearance(dbOP,request);
		if(vRetResult == null && strPageAction.length() == 0)
			strErrMsg = hrc.getErrMsg();
		else
			iSearchResult = hrc.getSearchCount();
	}	
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="CopyClearanceName()">
<form action="hr_clearance_search.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: CLEARANCE SEARCH PAGE ::::</strong></font></td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="4"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr> 
			<td height="25" width="3%">&nbsp;</td>
			<td width="20%">Clearance Type </td>
			<% 	
				if (vEditInfo != null) 
					strTemp = (String)vEditInfo.elementAt(0);
				else
					strTemp = WI.fillTextValue("clearance_type"); 
			%>
		    <td colspan="3" height="25">
			<select name="clearance_type" onChange="CopyClearanceName()">
				<%if(!(WI.fillTextValue("with_clearances")).equals("0")){%>
          		<option value="">ALL</option>
				<%}%>
          		<%=dbOP.loadCombo("clearance_type_index","clearance_name"," from hr_preload_clearance "+
					"order by clearance_name",strTemp,false)%>
          	</select>			</td>
		</tr>
		<tr>
			<td height="24">&nbsp;</td>
			<td>Status</td>
			<td colspan="3">
				<select name="pt_ft" onChange="ReloadPage();">
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
		<%if(bolIsSchool){%>
		<tr>
			<td height="24">&nbsp;</td>
			<td>Employee Category</td>
			<td colspan="3">
				<select name="employee_category" onChange="ReloadPage();">          
				<option value="">All</option>
				<%if (WI.fillTextValue("employee_category").equals("0")){%>
					<option value="0" selected>Non-Teaching</option>
				<%}else{%>
					<option value="0">Non-Teaching</option>				
				<%}if (WI.fillTextValue("employee_category").equals("1")){%>
					<option value="1" selected>Teaching</option>
				<%}else{%>
					<option value="1">Teaching</option>
				<%}%>
				</select></td>
		</tr>
		<%}
			String strCollegeIndex = WI.fillTextValue("c_index");	
		%>
		<tr> 
			<td height="24">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
			<td colspan="3">
				<select name="c_index" onChange="ReloadPage();">
					<option value="">N/A</option>
					<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%>
				</select>			</td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>Department/Office</td>
			<td colspan="3">
				<select name="d_index" onChange="ReloadPage();">
					<option value="">ALL</option>
					<%if (strCollegeIndex.length() == 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
					<%}else if (strCollegeIndex.length() > 0){%>
						<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
					<%}%>
				</select></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td>Employee ID </td>
			<td width="25%">
				<input name="user_index" type="text" size="16" value="<%=WI.fillTextValue("user_index")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('user_index','user_index_');">
					<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>				</td>
		    <td width="52%"><label id="user_index_"></label></td>
		</tr>
		<tr> 
			<td height="10" colspan="5"><hr size="1" color="#000000"></td>
		</tr>
		<tr>
			<td height="10" colspan="5">OPTION:</td>
		</tr>
		<tr> 
			<td height="10">&nbsp;</td>
		  <td colspan="4">
		<%
			strTemp = WI.getStrValue(WI.fillTextValue("with_clearances"),"1");
			if(strTemp.equals("1")) {
				strTemp = " checked";
				strErrMsg = "";
			}
			else {
				strTemp = "";	
				strErrMsg = " checked";
			}
		%>
    <input type="radio" name="with_clearances" value="1"<%=strTemp%> onClick="ReloadPage();"> 
    View Employees With Uncleared Posted Clearance(s)
    <input type="radio" name="with_clearances" value="0"<%=strErrMsg%> onClick="ReloadPage();">
View Employees w/out Posted Clearance(s)</td>
	</tr>
		<td height="10">&nbsp;</td>
		<td colspan="4">
		<%
			if(WI.fillTextValue("view_all").length() > 0)
				strTemp = " checked";				
			else
				strTemp = "";
		%>
		<input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();"> 
		View ALL </td>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    	<tr> 
      		<td width="3%" height="29">&nbsp;</td>
      		<td>SORT BY :</td>
      		<td height="29">
				<select name="sort_by1">
        			<option value="">N/A</option>
					<%=hrc.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      			</select>			</td>
      		<td height="29">
				<select name="sort_by2">
        			<option value="">N/A</option>
					<%=hrc.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>      
				</select>			</td>
	      	<td height="29">
				<select name="sort_by3">
        			<option value="">N/A</option>        
					<%=hrc.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      			</select>			</td>
    	</tr>
    	<tr> 
      		<td height="15">&nbsp;</td>
      		<td width="11%" height="15">&nbsp;</td>
      		<td>
				<select name="sort_by1_con">
       				<option value="asc">Ascending</option>
        			<%
						if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        					<option value="desc" selected>Descending</option>
        				<%}else{%>
        					<option value="desc">Descending</option>
        				<%}%>
      			</select>			</td>
      		<td>
				<select name="sort_by2_con">
        			<option value="asc">Ascending</option>
        			<%
						if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
							<option value="desc" selected>Descending</option>
						<%}else{%>
							<option value="desc">Descending</option>
						<%}%>
				</select>			</td>
			<td>
				<select name="sort_by3_con">
					<option value="asc">Ascending</option>
					<%
						if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
							<option value="desc" selected>Descending</option>
						<%}else{%>
							<option value="desc">Descending</option>
						<%}%>
				</select>			</td>
    	</tr>
		<tr>
			<td height="10" colspan="5">&nbsp;</td>
		</tr>
		<tr> 
			<td height="10">&nbsp;</td>
			<td height="10">&nbsp;</td>
			<td height="10" colspan="3">
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
				onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font></td>
		</tr>
  	</table>    
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>   
		<% if (vRetResult != null && vRetResult.size() > 0 ){%>
			<td height="10" colspan="2"><div align="right"><font size="2">Number of Employees / rows Per Page :</font><font>
				<select name="num_rec_page">
				<% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
					for(i = 10; i <=40 ; i++) {
						if ( i == iDefault) {%>
							<option selected value="<%=i%>"><%=i%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%></option>
				<%}}%>
				</select>
				<a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
				<font size="1">click to print</font></font></div></td>
		<%}%>
		</tr>
		<tr>
		<%
			int iPageCount = 1;
			if(vRetResult!=null && vRetResult.size() > 0){
				if(WI.fillTextValue("view_all").length() == 0){
					iPageCount = iSearchResult/hrc.defSearchSize;		
					if(iSearchResult % hrc.defSearchSize > 0) 
						++iPageCount;
					strTemp = " - Showing("+hrc.getDisplayRange()+")";
				}
				else
					strTemp = " - Showing All";
		%>
			<td><strong>TOTAL RESULT: <%=iSearchResult%><%=strTemp%></strong></td>
		<%}
			if(iPageCount > 1){
		%>
		    <td><div align="right"><font size="2">Jump To page:
				<select name="jumpto" onChange="SearchEmployee();">
				<%
					strTemp = request.getParameter("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0)
						strTemp = "0";
					i = Integer.parseInt(strTemp);
					if(i > iPageCount)
						strTemp = Integer.toString(--i);
		
					for(i =1; i<= iPageCount; ++i ){
						if(i == Integer.parseInt(strTemp) ){%>
							<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}
				}%>
				</select>
				</font></div></td>
		</tr>
		<%}%>
	</table>
<% if (vRetResult != null &&  vRetResult.size() > 0) {
	boolean bolIsWthBenefit = WI.fillTextValue("with_clearances").equals("1");
%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
  	</table>
	
  	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder" align="center"><strong>LIST OF EMPLOYEES</strong></td>
		</tr>
    	<tr style="font-weight:bold;" align="center">
			<td width="5%" class="thinborder">SL#</td>
			<td width="15%" class="thinborder">EMPLOYEE ID </td> 
			<td width="35%" height="23" class="thinborder">EMPLOYEE NAME </td>
			<td width="45%" class="thinborder">DEPARTMENT/OFFICE</td>
			<%if(bolIsWthBenefit){%>
			<%}%>
		</tr>
    	<% 
			int iCount = 1;
	   		for (i = 0; i < vRetResult.size(); i+=8,iCount++){
		%>
    	<tr>
      		<td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      		<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td> 
      		<td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;
			<font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
					(String)vRetResult.elementAt(i+5), 4).toUpperCase()%></strong></font></strong></font></td>
				<%
					if((String)vRetResult.elementAt(i + 6)== null || (String)vRetResult.elementAt(i + 7)== null)
						strTemp = " ";			
					else
						strTemp = " - ";
				%>
      		<td class="thinborder">&nbsp;
	   			<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"")%></td>
   		</tr>
    	<%} //end for loop%>
	</table>
	<% } // end vRetResult != null && vRetResult.size() > 0 %>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="print_page">
	<input type="hidden" name="searchEmployee" > 
	<input type="hidden" name="page_action">	
	<input type="hidden" name="clearance_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>