<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRTaxStatus" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Tax Status batch</title>
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
function ReloadPage() {
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function SearchEmployee() {
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function ViewRecords(){
	document.form_.print_page.value="";	
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}

function SaveData() {
	document.form_.save_data.value = "1";
	document.form_.print_page.value = "";
	document.form_.searchEmployee.value = "1";
	document.form_.save.disabled = true;
	//document.form_.hide_save.src = "../../../../images/blank.gif";
	document.form_.submit();
	//this.SubmitOnce('form_');
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" 	method="post" action="./tax_status_batch.jsp">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;	

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-TAX STATUS(BATCH)","tax_status_batch.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");

	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-TAX STATUS"),"0"));
		if(iAccessLevel == 0) 
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
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
	PRTaxStatus RptPay = new PRTaxStatus();
	Vector vRetResult = null;	
	String[] astrTaxStatus = {"Zero Exemption","Single","Head of the Family","Married","Not Set"};
	String[] astrExemptionName    = {"Zero", "Single","Head of Family", "Head of Family 1 Dependent (HF1)", 
																	"Head of Family 2 Dependents (HF2)","Head of Family 3 Dependents (HF3)", 
																	"Head of Family 2 Dependents (HF4)", "Married Employed", 																	 
																	 "Married Employed 1 Dependent (ME1)", "Married Employed 2 Dependents (ME2)",
																	 "Married Employed 3 Dependents (ME3)", "Married Employed 4 Dependents (ME4)"};
	String[] astrExemptionVal     = {"0","1","2","21","22","23","24","3","31","32","33","34"};

	String[] astrSortByName    = {"Employee ID","Firstname","Lastname","Tax Status"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","tax_status"};
	String strStatus = null;
	String strDependent = null;
	if(WI.fillTextValue("save_data").length() > 0){
		if((RptPay.operateOnTaxStatusBatch(dbOP, request, 1)) == null)
			strErrMsg = RptPay.getErrMsg();
		else
			strErrMsg = "Operation success!";		
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
		vRetResult = RptPay.operateOnTaxStatusBatch(dbOP, request, 4);
 		if(vRetResult == null && WI.fillTextValue("save_data").length() == 0){
			strErrMsg = RptPay.getErrMsg();
		}else{
			iSearchResult = RptPay.getSearchCount();
		}
	}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        PAYROLL - 
       EMPLOYEES TAX STATUS PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;<strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <%
			strTemp = WI.fillTextValue("tax_status");
		%>
    <tr>
      <td width="3%" height="18">&nbsp;</td>
      <td width="20%">Tax Status:</td>
      <td width="77%"><select name="tax_status">
        <option value="">ALL</option>
        <%for(i = 0; i <= 11; ++i ){
				if(astrExemptionVal[i].equals(strTemp)){%>
        <option selected value="<%=astrExemptionVal[i]%>"><%=astrExemptionName[i]%></option>
        <%}else{%>
        <option value="<%=astrExemptionVal[i]%>"> <%=astrExemptionName[i]%></option>
        <%}
			}%>
      </select></td>
    </tr>
<tr>
      <td width="3%" height="24">&nbsp;</td>
      <td width="20%">Status</td>
      <td width="77%" colspan="3"><select name="pt_ft" onChange="ReloadPage();">
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
		<%}%>		
     <tr> 
      <td>&nbsp;</td>
      <%
		String strCollegeIndex = WI.fillTextValue("c_index");
		%>
      <td> <%if(bolIsSchool){%>College<%}else{%>Division<%}%> </td>
      <td> <select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select></td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td>Department/Office</td>
      <td><select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Office/Dept filter</td>
      <td><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
		<tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10" colspan="3"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
        <label id="coa_info"></label>			</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
			<%
				strTemp = "";
				if(WI.fillTextValue("inc_resigned").length() > 0)
					strTemp = " checked";
			%>
      <td><input type="checkbox" name="inc_resigned" value="1" <%=strTemp%>>include resigned employees in report</td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10" colspan="5">OPTION:</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
View with tax status
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View Employees w/out tax status</td>
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
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">        View ALL </td>
    </tr>		
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :<strong></strong></td>
      <td height="29"> <select name="sort_by1">
          <option value="">N/A</option>
          <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select></td>
      <td height="29"><select name="sort_by2">
          <option value="">N/A</option>
          <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select></td>
      <td height="29"><select name="sort_by3">
          <option value="">N/A</option>
          <%=RptPay.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="11%" height="15">&nbsp;</td>
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
				<!--
				<a href="javascript:SearchEmployee()"> <img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a> 
				-->
				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
				<font size="1">click to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <%	
		if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/RptPay.defSearchSize;		
	if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr> 
      <td align="right"><font size="2">Jump To page: 
        <select name="jumpto" onChange="SearchEmployee();">
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
      </font></td>
    </tr>
	<%}
	}%>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="7%" height="25" align="center" class="thinborder"><font size="1"><strong>COUNT 
      NO.</strong></font></td>
      <td width="14%" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE ID</strong></font></td>
      <td width="37%" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE NAME</strong></font></td>
      <td width="31%" align="center" class="thinborder"><font size="1"><strong>TAX STATUS</strong></font></td>
      <td width="11%" align="center" class="thinborder"><font size="1"><strong>SELECT ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
    </tr>
    <%
	int iRow = 1;
	for(i = 0; i < vRetResult.size(); i+=8, iRow ++){%>
    <tr> 
			<input type="hidden" name="user_<%=iRow%>" value="<%=vRetResult.elementAt(i)%>">
      <td height="25" class="thinborder">&nbsp;<%=iRow%></td>
      <td class="thinborder"><font size="1">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></font></td>
        <%
				strStatus = WI.getStrValue((String)vRetResult.elementAt(i+5),"4");
				strDependent = (String)vRetResult.elementAt(i+6);
					if(strStatus.length() == 2){
						strDependent = strStatus.substring(1,2);
						strStatus = strStatus.substring(0,1);						
					}
  		%>
      <td class="thinborder">&nbsp;<%=astrTaxStatus[Integer.parseInt(strStatus)]%> <%=WI.getStrValue(strDependent,""," dependent(s)","")%></td>
      <td align="center" class="thinborder"><input type="checkbox" name="save_<%=iRow%>" value="1" checked tabindex="-1"></td>
    </tr>
    <%}%>
		<input type="hidden" name="emp_count" value="<%=iRow%>">
  </table>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
		<%
			strTemp = WI.fillTextValue("set_status");
		%>
    <td>Tax Status : 
      <select name="set_status">
       <%for(i = 0; i <= 11; ++i ){
				if(astrExemptionVal[i].equals(strTemp)){%>
      <option selected value="<%=astrExemptionVal[i]%>"><%=astrExemptionName[i]%></option>
      <%}else{%>
      <option value="<%=astrExemptionVal[i]%>"> <%=astrExemptionName[i]%></option>
      <%}
			}%>
    </select></td>
  </tr>
  
  <tr>
    <td align="center">
			<%if(iAccessLevel > 1){%>
		<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">
      <font size="1"> click to save entries</font>      
      <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
			onClick="javascript:CancelRecord();">
      <font size="1"> click to cancel or go previous</font>
			<%}%>
		</td>
  </tr>
	</table>
  <%}%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
    <tr> 
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>  
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_page">
	<input type="hidden" name="save_data">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>