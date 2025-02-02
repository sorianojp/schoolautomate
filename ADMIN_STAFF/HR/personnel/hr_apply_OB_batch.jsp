<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining,hr.HRInfoServiceRecord"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
		
	if(bolIsSchool)
		strTemp = "College";
	else
		strTemp = "Division";
	String[] astrSortByName    = {"Employee ID","Firstname","Lastname",strTemp,"Department"};
	String[] astrSortByVal     = {"id_number","user_table.fname","lname","c_name","d_name"};	

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Official Business.</title>
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
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
//function viewInfo(){
//	this.SubmitOnce("form_");
//}
function SearchEmployee(){	
	document.form_.searchEmployee.value="1";	
	this.SubmitOnce("form_");
}
function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.searchEmployee.value="";	
	document.form_.submit();
}


function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function CancelRecord(strEmpID){
	location = "./hr_apply_OB_batch.jsp?my_home=<%=WI.fillTextValue("my_home")%>";
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
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}



</script>
<%
	String strErrMsg = null;	
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Logout(Official Time)","hr_employee_logout.jsp");

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

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_employee_logout.jsp");
	if(strSchCode.startsWith("TSUNEISHI") && iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","OFFICIAL BUSINESS",request.getRemoteAddr(),
														"hr_employee_logout.jsp");
	}

if (strTemp == null) 
	strTemp = "";
//

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
Vector vRetResult = null;
HRInfoLicenseETSkillTraining hrPx = new HRInfoLicenseETSkillTraining();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

int iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"4"));

strTemp = "1";
if (strTemp.trim().length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication(); 
	
	if(iAction == 1){
		vRetResult = hrPx.operateOnBatchOBApplication(dbOP,request,1);
		if (vRetResult == null && strErrMsg == null)
			strErrMsg= hrPx.getErrMsg();
		else
			strErrMsg= "OB successfully saved.";	
	}	
	if(WI.fillTextValue("searchEmployee").length() > 0){
		vRetResult = hrPx.operateOnBatchOBApplication(dbOP,request,4);
		//vRetResult = hrPx.operateOnEmpLogout(dbOP,request,4);
		if (vRetResult == null && strErrMsg == null)
			strErrMsg= hrPx.getErrMsg();
		else
			iSearchResult = hrPx.getSearchCount();		
	}			
}
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_apply_OB_batch.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
           OFFICIAL BUSINESS BY BATCH::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
        
<!-- start of employee search -->		
		
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr> 
	<tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
      <label id="coa_info"></label></td>
    </tr>   
    <tr>
      <td height="24">&nbsp;</td>
      <td>Status</td>
      <td>
	  <%	strTemp = WI.fillTextValue("pt_ft"); %>
			 <select name="pt_ft">
				<option value="" <%=strTemp.equals("")?"selected":"" %> >All</option>
				<option value="0" <%=strTemp.equals("0")?"selected":"" %> >Part-time</option>
				<option value="1" <%=strTemp.equals("1")?"selected":"" %> >Full-time</option>
			</select>
	 </td>
    </tr>
		<tr>
		  <td height="24">&nbsp;</td>
		  <td>Position</td>
		  <td><select name="emp_position">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE " +
				" where IS_DEL=0 order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_position"), false)%>
      </select></td>
	  </tr>
		<%if(bolIsSchool){%>
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td>
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
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> <select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td>
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
      <td height="10">&nbsp;</td>
      <td>Office/Dept filter</td>
      <td><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
    </tr>
    
    <tr> 
      <td height="10" colspan="3"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10" colspan="3">OPTION:</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">
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
      <td>SORT BY :</td>
      <td height="29"><select name="sort_by1">
        <option value="">N/A</option>
					<%=hrPx.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>

      <td height="29"><select name="sort_by2">
        <option value="">N/A</option>
					<%=hrPx.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>      
				</select></td>

      <td height="29"><select name="sort_by3">
        <option value="">N/A</option>        
					<%=hrPx.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
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
        <input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
        <font size="1">click to display employees</font></td>
    </tr>
  </table> 
		
<!-- end of employee search  -->	


<% if(vRetResult != null && vRetResult.size() > 0) {%>

<!-- start of OB form -->

	 <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
	 <tr> 
            <td width="20%">&nbsp;</td>
            <td width="80%">&nbsp; </td>
  </tr>
	 <tr> 
		  <td height="10" colspan="3"><hr size="1" color="#000000"></td>
	 </tr>     
	<tr> 
      <td width="100%"><img src="../../../images/sidebar.gif" width="11" height="270" align="right">	  
        <%if(!bolMyHome){%>
       	<table width="90%" border="0" align="center" cellpadding="2" cellspacing="0">          		  
          <tr> 
            <td>Purpose </td>
            <td>
			<%strTemp = WI.fillTextValue("purpose");%> 
			<textarea name="purpose" cols="48" rows="3" class="textbox" 
			  onfocus="CharTicker('form_','256','purpose','count_');style.backgroundColor='#D3EBFF'" 
			  onBlur ="CharTicker('form_','256','purpose','count_');style.backgroundColor='white'" 
			  onkeyup="CharTicker('form_','256','purpose','count_');"><%=strTemp%></textarea>
					  <br>
              <font size="1">Available Characters</font> 
              <input name="count_" type="text" class="textbox_noborder" size="5" maxlength="5" readonly="yes" tabindex="-1"></td>
          </tr>
          <tr> 
            <td>Destination</td>
            <td> 
			<% strTemp = WI.fillTextValue("destination"); %>
			<input name="destination" type="text" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  
			value="<%=strTemp%>" size="48" maxlength="64">
			</td>
          </tr>
          <tr>
            <td colspan="2" style="font-size:9px; font-weight:bold; color:#0000FF">
<%
strTemp = WI.fillTextValue("less_oneday");
boolean bolIsOBLessOneDay = strTemp.equals("1");
if(bolIsOBLessOneDay) 
	strTemp = " checked";
else	
	strTemp = "";
%>
			<input type="checkbox" name="less_oneday" value="1" <%=strTemp%> onClick="document.form_.searchEmployee.value='1';document.form_.submit();"> OB is less than one day (must enter time of departure and Arrival) </td>
          </tr>
          <tr> 
            <td>Date Range </td>
            <td> 
<%

	strTemp = WI.fillTextValue("date_logout");		

	if (strTemp == null || strTemp.length() == 0) 
		strTemp = WI.getTodaysDate(1);
%> 
		<input name="date_logout" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		onKeyUp="AllowOnlyIntegerExtn('form_','date_logout','/')" value="<%=strTemp%>" size="15">
        <a href="javascript:show_calendar('form_.date_logout');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a> &nbsp; 
<%if(!bolIsOBLessOneDay){%>        
		<font size="1">to </font>
<%
	strTemp = WI.fillTextValue("date_logout_to");		
%> 
		<input name="date_logout_to" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		onKeyUp="AllowOnlyIntegerExtn('form_','date_logout_to','/')" value="<%=strTemp%>" size="15">
        <a href="javascript:show_calendar('form_.date_logout_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../images/calendar_new.gif" border="0"></a>
<%}%>			</td>
          </tr>
<%if(bolIsOBLessOneDay){%>
          <tr> 
            <td>Time of Departure</td>
            <td> 
<%
strTemp = "";
int[] iTimeConverted = {0,0,0};
	strTemp = WI.fillTextValue("hr_dep");
%> 
		<input name="hr_dep" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';" 
	  onKeyUp="AllowOnlyInteger('form_','hr_dep')" value="<%=strTemp%>" size="2" maxlength="2" >
              : 
<%
	strTemp = WI.fillTextValue("min_dep");
%> 
		<input name="min_dep" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			  onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','min_dep')" 
			  value="<%=strTemp%>" size="2" maxlength="2"> <select name="ampm_dep">
                <option value="0" >AM</option>
<% 
	strTemp = WI.fillTextValue("ampm_dep");		

if (strTemp.equals("1"))
	strTemp = "selected";
else	
	strTemp = "";
%>
                <option value="1" <%=strTemp%>>PM</option>
              </select> </td>
          </tr>
          <tr> 
            <td height="15">Time of Arrival</td>
            <td height="15"> 
<%
	strTemp = WI.fillTextValue("hr_arr");
%> 
		 <input name="hr_arr" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  onKeyUP="AllowOnlyInteger('form_','hr_arrive')" 
	  value="<%=strTemp%>" size="2" maxlength="2" >
              : 
<%
	strTemp = WI.fillTextValue("min_arr");		
%> 
              
			  <input name="min_arr" type="text" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','min_arr')"
	  onKeyUp="AllowOnlyInteger('form_','min_arr')"
	  value="<%=strTemp%>" size="2" maxlength="2"> 
	  		<select name="ampm_arr" >
                <option value="0" >AM</option>
<%  
	strTemp = WI.fillTextValue("ampm_arr");		

if (strTemp.equals("1"))
	strTemp = "selected";
else	
	strTemp = "";
%>
                <option value="1" <%=strTemp%>>PM</option>
              </select> </td>
          </tr>
<%}%>
          <tr>
            <td height="15">Comments</td>
            <td height="15">
<%
	strTemp = WI.fillTextValue("remarks");		
%> 
				<textarea name="remarks" cols="48" rows="3" class="textbox"><%=strTemp%></textarea>			</td>
          </tr>
          <tr>
            <td height="15">&nbsp;</td>
            <td height="15">
<% 
	strTemp = WI.fillTextValue("is_verified");

if (strTemp.equals("1")) 
	strTemp = "checked";
else 
	strTemp = "";
%>
			<input type="checkbox" name="is_verified" value="1" <%=strTemp%>>
              <font size="1">tick if Logout is verified</font></td>
          </tr>
        </table>


<!-- end of OB form -->
	
<!-- start of paging -->	
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">  
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/hrPx.defSearchSize;		
	if(iSearchResult % hrPx.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr>
      <td><div align="right"><font size="2">Jump To page:
        <select name="jumpto" onChange="SearchEmployee();">
      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
                  <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                  <%}else{%>
                  <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                  <%
					}
			}
			%>
          </select>&nbsp;&nbsp;&nbsp;
      </font></div></td>
    </tr>
    <%} // end if pages > 1
		}// end if not view all%>
  </table>
	
<!-- end of paging --->	



<!-- start for list of employees  -->
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
		  <td height="10">&nbsp;</td>
		</tr>
  	</table>
 	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  <td height="20" colspan="8" align="center" bgcolor="#B9B292" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
		</tr>
		<tr>
		  <td width="5%" class="thinborder">&nbsp;</td>
		  <td width="10%" class="thinborder">&nbsp;</td> 
		  <td width="33%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME</font></strong></td>
		  <td width="33%" height="23" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
		  <td width="12%" align="center" class="thinborder">
		  	<font size="1"><strong>SELECT ALL<br></strong>
			<input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
		  	</font>
		  </td>
		</tr>
    	<% 
			int iCount = 1;
	   		for (int i = 0; i < vRetResult.size(); i+=7,iCount++){		 
		 %>
    	<tr>     		
			<input type="hidden" name="emp_id_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">
			
		 	<td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      		<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      		<td height="25" class="thinborder">
				<font size="1">
					<strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font>
			</td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
     		 <% 
				 strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5),"");
				 if(strTemp.length() < 1 )
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6),"");	  
			 %>	
      		 <td align="left" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=strTemp%>&nbsp;</strong></font></td>
      		 <td align="center" class="thinborder">        
				<input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1">
			</td>
   		</tr>
    <%} //end for loop%>
    <input type="hidden" name="emp_count" value="<%=iCount%>">
    <tr>
      <td height="25" colspan="8" align="center">&nbsp;</td>
    </tr>
	
	
	
	
<!-- end of list of employees  -->	
	
		<table width="92%" border="0" align="center" cellpadding="2" cellspacing="0">
          <tr> 
            <td height="15" colspan="2" valign="bottom">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2"><div align="center"> 
                <% if (iAccessLevel > 1){%>
						<a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
						<font size="1">click to save entries</font>
                		<font size="1">&nbsp;<a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a>click 
                to cancel and clear entries</font> 
                <%} // if iAccessLevel > 1%>
              </div></td>
          </tr>
        </table> 
<%}//do not show the saving if coming from home page..%>
	  </td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
    </tr>
  </table>
<%} //end of if vRetResult != null %>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
   <input type="hidden" name="searchEmployee" > 
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
