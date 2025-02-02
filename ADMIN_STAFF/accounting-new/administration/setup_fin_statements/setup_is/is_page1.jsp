<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PageAction(strAction,strIndex){
	if(strAction == 0){
		if(!confirm('Are you sure you want to remove this information.'))
			return;
	}
	document.form_.page_action.value = strAction;
	document.form_.info_index.value = strIndex;
	document.form_.submit();
}
function PreparedToEdit(strIndex) {
	document.form_.info_index.value = strIndex;
	document.form_.preparedToEdit.value = "1";
	document.form_.page_action.value = "";
	document.form_.submit();
}
function ViewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function GoToPage2(strISIndex) {
	var loadPg = "./is_page2.jsp?is_main_index="+strISIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=700,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
	win.focus();
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.IncomeStatement,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-IncomeStatement-Set up Income Statement","is_page1.jsp");
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
														"Accounting","IncomeStatement",request.getRemoteAddr(), 
														"is_page1.jsp");	
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
	
	IncomeStatement incomeState = new IncomeStatement();	
	Vector vRetResult        = null;
	Vector vEditInfo         = null;
	
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"),"0");
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(incomeState.operateOnISSetupMain(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = incomeState.getErrMsg();
		else {
			strErrMsg = "Income Statement set up information updated successfully.";	
			strPreparedToEdit = "0";
		}
	}
	vRetResult = incomeState.operateOnISSetupMain(dbOP, request, 4);
	if(strPreparedToEdit.equals("1"))
		vEditInfo = incomeState.operateOnISSetupMain(dbOP, request, 3);
%>
	

<form name="form_" method="post" action="is_page1.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B5AB73"> 
      <td height="25" align="center" style="font-weight:bold; color:#FFFFFF">:::: SETUP FOR INCOME STATEMENT - ENTRIES PAGE ::::</td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="0" cellspacing="0">
    <tr> 
      <td colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Chart of account Classification Reference : 
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("coa_cf");
%>
	  <select name="coa_cf">
<%=dbOP.loadCombo("COA_CF","CF_NAME"," from AC_COA_CF where not exists (select * from AC_SET_IS_MAIN where COA_CF_REF = coa_cf and is_valid =1) order by COA_CF asc",strTemp, false)%>
      </select>	  </td>
    </tr>
    <tr> 
      <td width="4%">&nbsp;</td>
      <td width="19%">Group Title : </td>
      <td width="77%">
		<%
		if(vEditInfo != null) 
			strTemp = (String)vEditInfo.elementAt(3);
		else	
			strTemp = WI.fillTextValue("group_title");
		%>
	  <input name="group_title" type="text" value="<%=strTemp%>" size="64" maxlength="256" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Group Order : </td>
      <td>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("group_order");

int iTemp = Integer.parseInt(WI.getStrValue(strTemp, "0"));	
String[] astrConvertToChar = {"","A","B","C","D","E","F","G","H"};
%>
	  <select name="group_order">
<%for(int i = 1; i < 9; ++i) {
	if(i == iTemp)
		strTemp = " selected";
	else	
		strTemp = "";
%>
		<option value="<%=i%>"<%=strTemp%>><%=astrConvertToChar[i]%></option>
<%}%>
        </select> </td>
    </tr>
    <tr>
      <td height="73">&nbsp;</td>
      <td colspan="2"><u>Group Total Location :</u> <br>       
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("total_loc");
	
if(strTemp.equals("0") || strTemp.length() == 0) {
	strTemp = " checked";
	strErrMsg = "";
}
else {
	strTemp = "";
	strErrMsg = " checked";
}


%>
        <input name="total_loc" type="radio" value="0" <%=strTemp%>> [Below] Show Total of Group Below Group Details <br>
				<input name="total_loc" type="radio" value="1" <%=strErrMsg%>> [In-line] ]Show Total of Group In-line with Group Title	  </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td colspan="2">Total Line Title : 
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("total_line_title");
%>
      <input name="total_line_title" type="text" value="<%=strTemp%>" size="64" maxlength="256" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="52">&nbsp;</td>
      <td colspan="2"><u>General Operation in Income Statement :</u> <br>
<%
if(vEditInfo != null) 
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("gen_op");

if(strTemp.equals("0") || strTemp.length() == 0) {
	strTemp = " checked";
	strErrMsg = "";
}
else {
	strTemp = "";
	strErrMsg = " checked";
}
%>
      <input name="gen_op" type="radio" value="0" <%=strTemp%>> Addition &nbsp;&nbsp;&nbsp;
     <input name="gen_op" type="radio" value="1"<%=strErrMsg%>> Subtraction	 </td></tr>
    
    <%
if(iAccessLevel ==2){%>
    <tr> 
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  <%
 			if(iAccessLevel > 1){
			if(strPreparedToEdit.equals("0")) {%>
        <input type="submit" name="12" value="Save Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">
      <%}else{%>
				<%
					if(vEditInfo != null)
						strTemp = (String)vEditInfo.elementAt(0);
					else
						strTemp = "0";
				%>
        <input type="submit" name="1" value="Edit Information" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='2';document.form_.info_index.value=<%=strTemp%>">
				&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="submit" name="1" value="Cancel Edit" style="font-size:11px; height:22px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='';document.form_.preparedToEdit.value='';document.form_.date_taken.value='';document.form_.license_no.value='';document.form_.remarks.value=''">
			<%}
			}%>			</td>
    </tr>
    <%}%>
    <tr> 
      <td colspan="3" align="right"><input type="submit" name="13" value="View Income Statement Structure" style="font-size:11px; height:22px;border: 1px solid #FF0000;" ></td>
    </tr>
    <tr>
      <td colspan="3" align="right">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null){%>  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="7" bgcolor="#B9B292" class="thinborder" align="center"><font color="#FFFFFF"><strong>:: TITLES/NAME TO APPEAR IN INCOME STATEMENT :: </strong></font></td>
    </tr>
    <tr> 
      <td width="19%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Group Title</td>
      <td width="7%" height="25" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Group Order</td>
      <td width="14%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Total Location</td>
      <td width="13%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Total Line Title</td>
      <td width="13%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">General Operation </td>
      <td width="13%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Edit/Delete</td>
      <td width="13%" class="thinborder" align="center" style="font-size:9px; font-weight:bold">Update Sub item </td>
    </tr>
<%
for(int i = 0 ; i < vRetResult.size(); i += 8) {%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 3)%></td>
			<%
				strTemp =(String)vRetResult.elementAt(i + 4);
				strTemp = astrConvertToChar[Integer.parseInt(strTemp)];
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i + 5);
				if(strTemp.equals("0"))
					strTemp = "Below";
				else
					strTemp = "In-line";
				
			%>			
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i + 7);
				if(strTemp.equals("0"))
					strTemp = "Addition";
				else
					strTemp = "Subtraction";
				
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
      <td align="center" class="thinborder">
      <%if(iAccessLevel > 1){%>
				<a href="javascript:PreparedToEdit('<%=vRetResult.elementAt(i)%>');">Edit</a>
      <%}else{%>
	      &nbsp;
      <%}%>
      <%if(iAccessLevel == 2){%>      
				<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>');">Remove</a>
      <%}else{%>
  	    &nbsp;
      <%}%></td>
      <td class="thinborder"><a href="javascript:GoToPage2('<%=vRetResult.elementAt(i + 1)%>');"><img src="../../../../images/update.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" >
    
    <tr>
      <td height="27" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="27" bgcolor="#B5AB73">&nbsp;</td>
    </tr>
  </table>


  <input type="hidden" name="page_action">
  <input type="hidden" name="info_index">
  <input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>