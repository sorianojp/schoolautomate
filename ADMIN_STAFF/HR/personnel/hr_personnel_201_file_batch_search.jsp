<%@ page language="java" import="utility.*,search.SearchEmployee,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	
	
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	if(strSchCode == null)
		strSchCode = "";
	
	
	boolean bolIsSchool = false;
	
	if ((new CommonUtil().getIsSchool(null)).equals("1")) 
		bolIsSchool= true;
		
		
	if(WI.fillTextValue("print_201").length() > 0) {
		String strStudList = null;
		int iMaxDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_disp"), "0"));
		for(int i =0; i < iMaxDisp; ++i) {
			if(WI.fillTextValue("sel_"+i).length() == 0)
				continue;
			if(strStudList == null)
				strStudList = WI.fillTextValue("sel_"+i);
			else	
				strStudList += ","+WI.fillTextValue("sel_"+i);
		}
		//System.out.println(strStudList);
		if(strStudList != null && strStudList.length() > 0) {
			request.getSession(false).setAttribute("batch_201",strStudList);
			response.sendRedirect("./hr_personnel_201_file_batch_print.jsp");
			return;
		}
		else	
			strErrMsg = "Student List not found for batch print.";
	}

%>



<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function ShowHideOthers(strSelFieldName, strOthFieldName,strTextBoxID)
{
	if( eval('document.search_util.'+strSelFieldName+'.selectedIndex') == 0)
	{
		eval('document.search_util.'+strOthFieldName+'.disabled=false');
		showLayer(strTextBoxID);
	}
	else
	{
		eval('document.search_util.'+strOthFieldName+'.value=\'\'');
		hideLayer(strTextBoxID);
		eval('document.search_util.'+strOthFieldName+'.disabled=true');
	}
	//if dob to is disabled, i am sure, it is hidden. 
	if(document.search_util.dob_to.disabled)
		hideLayer("dob_to_cal_");
	else	
		showLayer("dob_to_cal_");
}
function ReloadPage()
{
	document.search_util.searchEmployee.value = "";
	document.search_util.print_201.value = '';
	document.search_util.submit();
}
function SearchEmployee()
{
	document.search_util.searchEmployee.value = "1";
	document.search_util.print_201.value = '';
	document.search_util.submit();	
}
function ViewDetail(strStudID)
{
//popup window here. 
	var pgLoc = "./stud_info_view.jsp?stud_id="+escape(strStudID);
	var win=window.open(pgLoc,"EditWindow",'width=924,height=450,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function SetIDToCopy(strStudID) {
	document.search_util.id_to_copy.value = strStudID;
}
function CopyIDNumber() {
	if(document.search_util.opner_info.value.length ==0) {
		alert("Proceed copies ID to the caller page. Click Proceed only if search page is called clicking Search ICON.");
		return;
	}
	eval('window.opener.document.'+document.search_util.opner_info.value+'.value=\''+document.search_util.id_to_copy.value+'\'');
	window.opener.focus();
	self.close();
}
function PrintPg() {
	document.search_util.print_201.value = 1;
	document.search_util.submit();
}
function focusID() {
	document.search_util.id_number.focus();
}
function SelALL() {
	var selall = document.search_util.sel_all.checked;
	var objchkbox;
	var iMaxDisp = document.search_util.max_disp.value;
	for(i = 0; i < iMaxDisp; ++i) {
		eval('obj=document.search_util.sel_'+i);
		if(!obj)
			continue;
		obj.checked = selall;
	}
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();"  class="bgDynamic">
<%
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;


	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Employees","srch_emp.jsp");
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
//authenticate this user.
	// allow search employee only if the user is not a student / parent. 
	strTemp = (String)request.getSession(false).getAttribute("userId");
	if(strTemp == null)
		strErrMsg = "You are already logged out. Please login again.";
	else {
		strTemp = dbOP.mapOneToOther("user_table","id_number","'"+strTemp+"'","AUTH_TYPE_INDEX"," and is_valid = 1 and is_del = 0");
		if(strTemp == null || strTemp.compareTo("4") ==0 || strTemp.compareTo("6") ==0)//student or parent or not having any access
			strErrMsg = "You are not authorized to view Employee search page.";		
	}
	if(strErrMsg != null) {
		dbOP.cleanUP();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
			

//end of authenticaion code.
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=","greater","less"};
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Tenureship","Salary","Emp. Status","Emp. Type","D.O.B"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","doe","SALARY_AMT","user_status.status",
								"HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME","dob"};
String[] astrDropListBetween = {"Between","Equal to","Less than","More than"};
String[] astrDropListValBetween = {"BETWEEN","=","greater","less"};//check for between
String[] astrDropListValBetweenAGE = {"BETWEEN","=","less","greater"};//for age, less than and greater than is swapped.

int iSearchResult = 0;

SearchEmployee searchEmp = new SearchEmployee(request);
if(WI.fillTextValue("searchEmployee").compareTo("1") == 0){
	vRetResult = searchEmp.searchGeneric(dbOP);
	if(vRetResult == null)
		strErrMsg = searchEmp.getErrMsg();
	else	
		iSearchResult = searchEmp.getSearchCount();
}

%>
<form action="./hr_personnel_201_file_batch_search.jsp" method="post" name="search_util">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"  class="footerDynamic"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SEARCH EMPLOYEE PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%">Employee ID </td>
      <td width="9%"><select name="id_number_con">
          <%=searchEmp.constructGenericDropList(WI.fillTextValue("id_number_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select> </td>
      <td width="14%"><input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td width="9%">Gender</td>
      <td width="47%"> <select name="gender">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("gender").compareTo("1") == 0){%>
          <option value="1" selected>Female</option>
          <%}else{%>
          <option value="1">Female</option>
          <%}if(WI.fillTextValue("gender").compareTo("0") ==0){%>
          <option value="0" selected>Male</option>
          <%}else{%>
          <option value="0">Male</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><select name="lname_con">
          <%=searchEmp.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select></td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
	  <td>&nbsp;</td>
	  <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Firstname</td>
      <td><select name="fname_con">
          <%=searchEmp.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> 
        </select></td>
      <td><input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16"></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
   </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employment Status</td>
      <td colspan="2">
        <select name="current_status">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("status_index","status"," from user_status where IS_FOR_STUDENT=0 order by status asc",WI.fillTextValue("current_status"), false)%> 
        </select></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Position</td>
      <td colspan="2"><select name="emp_type_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME",
		  " from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type_index"), false)%> 
        </select></td>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td><% if (bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="2"><select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%
	strTemp = WI.getStrValue(WI.fillTextValue("c_index"),"0");

if(strTemp.compareTo("0") ==0)
	strTemp2 = "Offices";
else
	strTemp2 = "Department";
%>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> 
        </select></td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Office/Dept</td>
      <td colspan="2"><select name="d_index">
          <option value="">N/A</option>
          <%
strTemp3 = "";
strTemp3 = WI.fillTextValue("d_index");
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index="+strTemp+" or c_index is null) order by d_name asc",strTemp3, false)%> 
        </select></td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="25%">&nbsp;</td>
      <td width="64%"> <input type="image" src="../../../images/refresh.gif" onClick="SearchEmployee();"> 
        <font size="1">Click to search Employee.</font></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="3"><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
          <font size="1">click to print 201 Files </font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH RESULT</font></strong></div></td>
    </tr>
    <tr>
      <td width="66%" >&nbsp;</td>
      <td width="34%">&nbsp;</td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr align="center" style="font-weight:bold">
      <td  width="5%" ><font size="1">COUNT</font></td> 
      <td  width="12%" height="25" ><div align="center"><strong><font size="1">EMPLOYEE ID</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">NAME (LNAME,FNAME MI) </font></strong></div></td>
      <td width="4%"><div align="center"><strong><font size="1">GENDER</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">EMPLOYMENT STATUS</font></strong></div></td>
      <td width="9%"><div align="center"><strong><font size="1">EMPLOYMENT TYPE</font></strong></div></td>
      <td width="30%"><div align="center"><strong><font size="1"><%if(bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>/ OFFICE</font></strong></div></td>
      <td width="8%" align="center"><strong><font size="1">SELECT ALL <br><input type="checkbox" name="sel_all" onClick="SelALL()"></font></strong></td>
    </tr>
<%int j = 0;
for(int i = 0 ; i < vRetResult.size(); i +=13){%>
    <tr>
      <td><%=j + 1%></td> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td height="25"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td><%=(String)vRetResult.elementAt(i + 4)%></td>
      <td><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td>
	  <%  strTemp = (String)vRetResult.elementAt(i+6);
	  	  if (strTemp != null) 
		  	strTemp += WI.getStrValue((String)vRetResult.elementAt(i + 7),"/","","");
		  else
		  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 7),"&nbsp;"); %>	
	  <%=strTemp%>	  </td>
      <td><div align="center"><font size="1"> 
          <input type="checkbox" name="sel_<%=j++%>" value="<%=(String)vRetResult.elementAt(i + 1)%>">
          </font></div></td>
    </tr>
<%}//end of for loop to display employee information.%>
<input type="hidden" name="max_disp" value="<%=j%>">
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="69%" height="25">&nbsp;</td>
      <td width="31%">&nbsp;</td>
    </tr>
  </table>
<%}//only if vRetResult not null%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="selectValue">
<input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
<input type="hidden" name="print_page" value="1">
<input type="hidden" name="print_201" value="1">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>