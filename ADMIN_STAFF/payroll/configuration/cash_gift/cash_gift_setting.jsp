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
<title>Payroll Payslip</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.pageReloaded.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SaveRecord() {
	document.form_.page_action.value = "1";
	document.form_.print_page.value = "";
	document.form_.save.disabled = true;
	//document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}

function DeleteRecord(strInfoIndex, strEmpID){
  var vProceed = confirm('Remove ' + strEmpID + ' setting?');
  if(vProceed){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.searchEmployee.value = "1";
    document.form_.print_page.value = "";
	this.SubmitOnce("form_");
  }	
}
function CancelRecord(){
	document.form_.page_action.value = "";
	this.SubmitOnce('form_');
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}
function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}
function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PayrollConfig" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.
if (WI.fillTextValue("print_page").length() > 0){%>
	<jsp:forward page="./cash_gift_setting_print.jsp" />
	<% 
return;}


try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Cash Gift Setting","cash_gift_setting.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","CONFIGURATION",request.getRemoteAddr(),
														"cash_gift_setting.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.


PayrollConfig prConfig = new PayrollConfig();
Vector vRetResult = null;
String strPageAction = WI.fillTextValue("page_action");
String[] astrCategory = {"Staff","Faculty","Employees"};
String[] astrStatus = {"Part-Time","Full-Time",""};
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
String[] astrSortByName    = {"Employee ID",strTemp, "Department/Office", "Employment date"};
String[] astrSortByVal     = {"id_number", "info_faculty_basic.c_index", "info_faculty_basic.d_index","doe"};
int i = 0;
if(strPageAction.length() > 0){
	if(prConfig.operateOnUserGiftSetting(dbOP, request, Integer.parseInt(strPageAction)) == null){
		strErrMsg = prConfig.getErrMsg();
	} else {
		if(strPageAction.equals("1"))
			strErrMsg = "Schedule successfully posted.";		
		if(strPageAction.equals("0")){
			strErrMsg = "Schedule successfully removed.";		
		}			
	}
}

  if(WI.fillTextValue("searchEmployee").equals("1")){
	vRetResult = prConfig.operateOnUserGiftSetting(dbOP, request,  4);
	  if(vRetResult == null){
			strErrMsg = prConfig.getErrMsg();
	  }else{
			iSearchResult = prConfig.getSearchCount();
		}
  }

if(strErrMsg == null) 
strErrMsg = "";
%>

<body  class="bgDynamic">
<form name="form_" method="post" action="cash_gift_setting.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL: CASH GIFT SETTING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><strong><%=strErrMsg%></strong></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="20%">Cash Gift name </td>
	    <%
		  	strTemp = WI.fillTextValue("gift_index");
	  %>
      <td><select name="gift_index">     
	  	<option value="">Select Cash Gift Name</option>   
        <%=dbOP.loadCombo("set_index","gift_name", " from pr_cash_gift where is_valid = 1 and is_del = 0 " +
													" order by gift_name",strTemp,false)%>
      </select>
	  <%
		if((WI.fillTextValue("is_overwrite")).equals("1")){
			strTemp = " checked";
		}else{
			strTemp = "";
		}
	  %>
      <input name="is_overwrite" type="checkbox" value="1" <%=strTemp%>>
      <font size="1">(overwrite  setting for existing employees)</font></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee ID </td>
      <td><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Position</td>
	  <%//System.out.println("size " +WI.fillTextValue("pageReloaded"));	
		  	strTemp = WI.fillTextValue("position");		
	  %>	  
      <td> <select name="position">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 order by EMP_TYPE_NAME asc", strTemp, false)%> </select></td>
    </tr>	
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
	  <%
		strTemp = WI.fillTextValue("pt_ft");
		strTemp= WI.getStrValue(strTemp);
	  %>	  	  
      <td><select name="pt_ft">
          <option value="">ALL</option>
		  <%if (strTemp.equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if (strTemp.equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select></td>
    </tr>	
    <% 
	String strCollegeIndex = null;
	strCollegeIndex = WI.fillTextValue("c_index");
	strCollegeIndex = WI.getStrValue(strCollegeIndex);
	%>
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
	  <%
	 	strTemp = WI.fillTextValue("employee_category");
		strTemp= WI.getStrValue(strTemp);
	  %>	  	  	  
      <td>
	    <select name="employee_category">
          <option value="">ALL</option>
          <%if (strTemp.equals("0")){%>
		  <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}else if (strTemp.equals("1")){%>
		  <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>
          <%}else{%>
		  <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}%>
		</select> </td>
    </tr>
	<%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> <select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
	  <%
		  strTemp = WI.fillTextValue("d_index");
	  %>	  	  	  
      <td> 
				<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", strTemp,false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , strTemp,false)%> 
          <%}%>
        </select> 
				</label>
			</td>
    </tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td>Length of Service </td>
			<%
			strTemp = WI.fillTextValue("eligibility");
		  %>
      <td>
			<input name="eligibility" type= "text" class="textbox" value="<%=strTemp%>" size="10" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','eligibility');style.backgroundColor='white'"
			onKeyUp="AllowOnlyInteger('form_','eligibility')">
			<%
			strTemp = WI.fillTextValue("eligibility_unit");
			%>
			<select name="eligibility_unit">
          <option value="2" selected>month(s)</option>
          <%if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>year(s)</option>
          <%}else{%>
          <option value="3">year(s)</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="11" colspan="3"><hr size="1"></td>
    </tr>
    <tr>
      <td height="11" colspan="3">OPTION:</td>
    </tr>
    <tr>
      <td height="11" colspan="3"><%
	strTemp = WI.fillTextValue("with_schedule");
	strTemp = WI.getStrValue(strTemp,"1");
	if(strTemp.compareTo("1") == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="with_schedule" value="1"<%=strTemp%> onClick="ReloadPage();">
        View with gift setting
        <%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else
		strTemp = "";
	%>
	<input type="radio" name="with_schedule" value="0"<%=strTemp%> onClick="ReloadPage();">
View Employees without gift setting</td>
    </tr>	
  </table>
  <% strTemp = WI.getStrValue(WI.fillTextValue("with_schedule"),"1");
  if((strTemp).length() > 0){%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :<strong></strong></td>
      <td height="29"><select name="sort_by1">
          <option value="">N/A</option>
          <%=prConfig.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td height="29"><select name="sort_by2">
          <option value="">N/A</option>
          <%=prConfig.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
      </select></td>
      <td height="29"><select name="sort_by3">
          <option value="">N/A</option>
          <%=prConfig.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
      </select></td>
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
			<a href="javascript:SearchEmployee()"> <img src="../../../../images/form_proceed.gif" width="81" height="21" border="0"> </a> 
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">Click to display employee list to print.</font></td>
    </tr>
    <tr>
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
  <%}// end if (WI.fillTextValue("view_employees")).equals("1")%>
<% if(vRetResult != null && vRetResult.size() > 0  ) {%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td height="18"><div align="right"><font size="2"> Number of Employees / rows Per 
          Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 5; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    
    <tr bgcolor="#B9B292" class="thinborder"> 
	  <%
	  if((WI.fillTextValue("with_schedule")).equals("1"))
	    strTemp = "EMPLOYEES WITH CASH GIFT SETTING";
	  else
	    strTemp = "EMPLOYEES WITHOUT CASH GIFT SETTING";
	  
	  %>	
      <td height="23" colspan="6" align="center"><strong><%=strTemp%></strong></td>	  
    </tr>
    <tr bgcolor="#ffff99" class="thinborder">
      <td width="9%" align="center" class="thinborder"><strong><strong>EMPLOYEE ID </strong></strong></td> 
      <td width="31%" height="25" align="center" class="thinborder"><strong><strong>EMPLOYEE NAME </strong></strong></td>
      <td class="thinborder" width="21%" align="center"><strong><strong>OFFICE</strong></strong></td>
	    <td width="18%" align="center" class="thinborder"><strong>LENGTH OF SERVICE </strong></td>
	    <%
	  if((WI.fillTextValue("with_schedule")).equals("1")){
	  %>
      <td width="13%" align="center" class="thinborder"><strong>GIFT NAME </strong></td>
      <td align="center" class="thinborder"><strong>OPTION</strong></td>
	  <%}%>
    </tr>
    <% int iItems = 0;
			  int iCount =0;
 	   if((WI.fillTextValue("with_schedule")).equals("1")){
	   	iItems = 10;
	   }else{
	   	iItems = 8;
	   }
	   
	for(i = 0; i < vRetResult.size(); i += iItems, iCount++){		
	%>
    <tr bgcolor="#FFFFFF" class="thinborder">
      <%
		  	strTemp = (String)vRetResult.elementAt(i+1);
	  %>
      <td class="thinborder" >&nbsp;<%=strTemp%></td> 

      <td height="25" class="thinborder" >&nbsp;<font size="1"><strong><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>

      <%	   
	    if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
	  %>							
      <td class="thinborder" >&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5)," ")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6)," ")%> </td>
	    <td class="thinborder" ><%=(String)vRetResult.elementAt(i+7)%></td>
	    <%if((WI.fillTextValue("with_schedule")).equals("1")){%>	  
      <td class="thinborder" >&nbsp;<%=(String)vRetResult.elementAt(i+8)%></td>
      <td width="8%" align="center" class="thinborder" > 
			<%if(iAccessLevel == 2){%>       
        <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>", "<%=(String)vRetResult.elementAt(i+1)%>");'><img src="../../../../images/delete.gif" width="55" height="28" border="0" id="hide_save"></a>
				<%}else{%>
					n/a
				<%}%>
				</td>
      <%}%>
    </tr>
    <%} // end for loop%>
	  <tr class="thinborder">
      <td height="17" colspan="6" class="thinborder">RECORDS FOUND : <%=iCount%> </td>
    </tr>
    <tr> 
      <td height="25" colspan="6" align="center">
	    <%if(iAccessLevel > 1){%>
				<!--
				<a href='javascript:SaveRecord();'> <img src="../../../../images/save.gif" border="0" id="hide_save"></a> 
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveRecord();">				
				<font size="1"> click to save entries</font>
        <!--
			<a href="javascript:CancelRecord();"><img src="../../../../images/cancel.gif" border="0"></a> 
			-->
			  <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
			onClick="javascript:CancelRecord();">			
			  <font size="1"> click to cancel or go previous</font>
			  <%}%>			</td>
    </tr>	
	<%} // end if vRetResult != null && vRetResult.size() %>		
  </table>  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>	
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="pageReloaded">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>