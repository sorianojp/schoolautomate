<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>DEDUCTION PRIORITY SETTING</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.submit();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){			
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + 
	"&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+
	"&extra_cond="+escape(strExtraCond) +"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PageAction(strAction, strInfo){
    document.form_.page_action.value=strAction;
   	if(strInfo.length > 0)	  
	  document.form_.info_index.value = strInfo;
   document.form_.submit();   
}
function DeleteEntry(strIndex, strIsCollege){
	if(!confirm("Do you want to delete this entry?"))
   		return;
	document.form_.info_index.value = strIndex;
	document.form_.delete_is_college.value = strIsCollege;
	document.form_.page_action.value = "0";
	document.form_.submit();
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	String strTemp1 = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Deduction Priority","deduction_priority.jsp");
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
															"Payroll","CONFIGURATION",request.getRemoteAddr(),
															"deduction_priority.jsp");
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
	Vector vRetResult = null;
	PayrollConfig pc = new PayrollConfig();
	boolean bolLoadAll = false;//in case successfully added, i have to load college and dept both.. 

    strTemp = WI.fillTextValue("page_action");
	if(strTemp.length()>0){
		if(pc.operateCollegeDeptGroupNameNEU(dbOP,request,Integer.parseInt(strTemp), WI.fillTextValue("info_index"), WI.fillTextValue("delete_is_college"))==null)
			strErrMsg = pc.getErrMsg();
		else{
			if(strTemp.equals("0")) 
				strErrMsg = "Information successfully deleted.";
			else {
				strErrMsg = "Entry successfully recorded.";
				bolLoadAll = true;
			}
		}
	}
	
	vRetResult = pc.operateCollegeDeptGroupNameNEU(dbOP,request,4, "","");
	if(strErrMsg == null && vRetResult==null)
		strErrMsg =pc.getErrMsg();
	

%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="neu_group_col_dept.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic">
	  <font color="#FFFFFF" ><strong>:::: ASSIGN GROUP TO COLLEGE/DEARTMENT ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="11%">Group Name</td>
      <td width="84%">       
 	   <select name="group_name" style="width:250px;">
	   <% strTemp = WI.fillTextValue("group_name");	%>	
		<option value="">-</option>
        <%=dbOP.loadCombo("col_dept_grp_index  "," group_name "," from pr_neu_college_dept_group order by group_name ",strTemp,false)%>
	   </select> &nbsp;&nbsp;
		<a href='javascript:viewList("pr_neu_college_dept_group","col_dept_grp_index","group_name","Group Name","college,department ","col_dept_grp_index,col_dept_grp_index"," and is_del=0, and is_del =0 ","","group_name");'>
			<img src="../../../images/update.gif" border="0"></a>	  </td>
    </tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>College</td>
		<td>
			<select name="c_index" onChange="document.form_.d_index.selectedIndex = 0; ReloadPage();" style="width:300px;">
			<option value="">----</option>		
			<%			
			String strCIndex = "";
			if(bolLoadAll || WI.fillTextValue("d_index").length() == 0) 
				strCIndex = dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 and col_dept_grp_index is null order by c_name asc", WI.fillTextValue("c_index"), false);
			%>	
			 <%=strCIndex%> 
		     </select>		</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Department</td>
		<td>
		<select name="d_index"  style="width:300px;">
		<option value="">---</option>
		<% if(bolLoadAll || WI.fillTextValue("c_index").length() == 0){%>
		          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 and (c_index is null or c_index = 0) and col_dept_grp_index is null order by d_name asc", WI.fillTextValue("d_index"), false)%> 
		<%}%>				  
		</select>		</td>
	</tr>
    
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">
      <div align="left">
	 <a href="javascript:PageAction('1','');">
	 <img src="../../../images/save.gif" border="0"></a> <font size="1">click to save entries </font>
      &nbsp;&nbsp;
      <a href="javascript:ReloadPage();">
	  <img src="../../../images/cancel.gif" border="0" /></a><font size="1">click to cancel operation </font></div>     			
	   </td>
    </tr>
	
	<tr>
		<td colspan="3" height="25">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="3" height="25"><hr size="1"></td>
	</tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
          <td height="20" colspan="3" bgcolor="#B9B292" class="thinborder" align="center">
  		<strong>::: LIST OF GROUP NAME :::</strong></td>
      </tr>
     <tr>
	    <td width="55%" height="25" align="center" class="thinborder">Group Name</td>	
		<td class="thinborder" align="center">Option</td> 
    </tr>
	<%	  
	  int iIndexOf = 0;
	  String strGroupName = null;
	  String strPrevGroupName = "";
	  String strName = null;
	  for(int i =0; i < vRetResult.size(); i+=5){	  	  
		 strGroupName = (String)vRetResult.elementAt(i+4);
	  if(!strPrevGroupName.equals(strGroupName)){ 		
	  	strPrevGroupName  = strGroupName;
	  %>
	<tr>
		<td height="25" colspan="2" class="thinborder"><%=strGroupName%></td>
	</tr>	
	 <%}%>
	<tr>
		<td height="25"c class="thinborder" style="padding-left:15px;"><%=(String)vRetResult.elementAt(i+2)%></td>	
		<td class="thinborder">
	    <a href="javascript:DeleteEntry('<%=(String)vRetResult.elementAt(i+1)%>','<%=(String)vRetResult.elementAt(i+3)%>');"> 
	    <img src="../../../images/delete.gif" border="0" /></a> 		
		</td>	
	</tr>
	<%}//end of vRetResult loop%>
  </table>
	<%}//end of vRetResult !=null && vRetResult.size()>0%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <tr>
      <td height="25">&nbsp;</td>
    </tr>
   <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="delete_is_college">
<input type="hidden" name="info_index">
 </form>
</body>
</html>
<%
dbOP.cleanUP();
%>
