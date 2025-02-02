<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRCOAMapping" %>
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
<title>Employee Mapping</title>
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
function ReloadPage()
{	
	this.SubmitOnce('form_');
}
 
function SaveRecord(){
	document.form_.save_record.value = "1";
	this.SubmitOnce('form_');	
}

function DeleteRecord (strInfoIndex){
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "0";	
	this.SubmitOnce('form_');	
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	 var strCompleteName = document.form_.emp_id.value;
	 var objCOAInput = document.getElementById("search_");
	
	//var strCompleteName = eval('document.form_.'+strTextName+'.value');	
	//var objCOAInput = eval('document.getElementById("'+strLabelName+'")');
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
	document.getElementById("search_").innerHTML = "";
	//document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

function viewList(table,indexname,colname,labelname,tablelist, 
									strIndexes, strExtraTableCond,strExtraCond,
									strFormField){
//	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname+
//	"&opner_form_name=form_";
	document.form_.donot_call_close_wnd.value="0";
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}
function goToMain(){
	location = "./coa_main.jsp";
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
		
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-COA Config-Office Mapping","employee_mapping.jsp");
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
														"employee_mapping.jsp");
															
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	Vector vRetResult = null;
	PRCOAMapping prCOA = new PRCOAMapping();
	String strStatus = null;
	int iSearchResult = 0;
	int iCount = 0;
	String strPageAction = WI.fillTextValue("page_action");
	
	if(WI.fillTextValue("save_record").equals("1")){	
		if(prCOA.operateOnEmployeeMapping(dbOP, request, 1) == null)
			strErrMsg = prCOA.getErrMsg();
	}
	
	if(strPageAction.length() > 0){
		vRetResult = prCOA.operateOnEmployeeMapping(dbOP, request, Integer.parseInt(strPageAction));
		if(vRetResult == null)	
			strErrMsg = prCOA.getErrMsg();	
		else
			strErrMsg = "Operation Successful";
	}
	
	strErrMsg = WI.getStrValue(strErrMsg);	
 	vRetResult = prCOA.operateOnEmployeeMapping(dbOP, request, 4);
	if(vRetResult != null)
		iSearchResult = prCOA.getSearchCount();	

 	if(strErrMsg == null) 
		strErrMsg = "";
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./employee_mapping.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        PAYROLL : OFFICE MAPPING ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="27"><strong><a href="javascript:goToMain();">MAIN</a>&nbsp;&nbsp;<%=strErrMsg%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr> 
      <td width="100%" height="12" colspan="3">&nbsp;</td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
		
    <tr>
      <td height="25" width="3%">&nbsp;</td>
      <td width="20%">Mapping Header </td>
			<%
				strTemp = WI.fillTextValue("coa_map_main_index");
			%>
      <td width="77%">
			<select name="coa_map_main_index" onChange="ReloadPage();">
        <option value="">Select mapping header</option>
        <%=dbOP.loadCombo("coa_map_main_index","map_header_name", 
				" from pr_coa_map_main order by order_no",strTemp,false)%>
      </select></td>
    </tr>
    
    <tr>
      <td height="14" colspan="3"><hr size="1"></td>
    </tr>
  </table>  
	<%if(WI.fillTextValue("coa_map_main_index").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">			
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">Chart of account</td>
      <td width="77%">
			<select name="coa_debit">
         <%=dbOP.loadCombo("coa_debit","account_name,  complete_code"," from pr_coa_map " + 
													" join ac_coa on (coa_index = coa_debit) " +
													" where coa_map_main_index = " + WI.fillTextValue("coa_map_main_index") +
 													" order by account_name", WI.fillTextValue("coa_debit"), false)%>
      </select> 
			</td>
    </tr>
    <% 
		String strCollegeIndex = WI.fillTextValue("c_index");	
		%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="25"><select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td height="22">Office</td>
      <td height="22">
			<label id="load_dept">
			<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
      </select>
			</label></td>
    </tr>		
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr>
      <td width="3%" height="10">&nbsp;</td>      
			<%
				strTemp = WI.fillTextValue("view_all");
				if(strTemp.length() > 0)
					strTemp = "checked";	
				else
					strTemp = "";
			%>
			<td height="10" colspan="4">&nbsp;<input type="checkbox" name="view_all" value="1" <%=strTemp%> onClick="ReloadPage();">
			  view all </td>			
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td width="11%" height="10">&nbsp;</td>
      <td height="10" colspan="3"><font size="1" color="#000066">
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onclick="javascript:SaveRecord();" />
      </font><font size="1">click to save</font></td>
    </tr>
  </table>	
	<%}%>
  <% //System.out.println("vRetResult " + vRetResult);
  if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td align="right"> <%
		if(!WI.fillTextValue("view_all").equals("1")){
		int iPageCount = iSearchResult/prCOA.defSearchSize;
		if(iSearchResult % prCOA.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> Jump To page:
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
          <%
					}
			}
			%>
        </select>
        <%}
				}%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    	
    
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td class="thinborder" height="25" align="center">&nbsp;</td>
      <td class="thinborder" width="41%" align="center"><strong>CHART OF ACCOUNT </strong></td>
      <td class="thinborder" width="45%" align="center"><strong>DEPARTMENT/OFFICE</strong></td>
      <td width="9%" align="center" class="thinborder">&nbsp;</td>
    </tr>
    <% 	//System.out.println("size " +vRetResult.size());
		for(int i = 0; i < vRetResult.size(); i += 13,++iCount){		
			strStatus = "";		
		%>
    <tr bgcolor="#FFFFFF" class="thinborder"> 						
 			<input type="hidden" name="user_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>">
      <td width="5%" height="25" class="thinborder">&nbsp;<%=iCount+1%>.</td>
			<%
				strTemp = (String)vRetResult.elementAt(i + 8);
				strTemp +=  "<br> (" + (String)vRetResult.elementAt(i + 9) + ")";
			%>
      <td class="thinborder" >&nbsp;<%=strTemp%></td>
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 7)== null){
				if((String)vRetResult.elementAt(i + 5)== null && (String)vRetResult.elementAt(i + 7)== null)
					strTemp = "ALL";			
				else	
			  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>
      <td class="thinborder" >&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5)," ")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 7)," ")%>      </td>
      <td align="center" class="thinborder" ><font size="1">
        <input type="button" name="delete" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:DeleteRecord('<%=vRetResult.elementAt(i)%>');">
      </font></td>
    </tr>
	<%} // end for loop%>
	<input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
  <%} // end if vRetResult != null && vRetResult.size() %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="save_record">
  <input type="hidden" name="page_action"> 
	<input type="hidden" name="info_index"> 

	<!-- this is used to reload parent if Close window is not clicked. -->
		<input type="hidden" name="close_wnd_called" value="0">
		<input type="hidden" name="donot_call_close_wnd">
	<!-- this is very important - onUnload do not call close window -->
	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>