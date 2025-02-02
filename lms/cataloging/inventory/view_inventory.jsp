<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../css/reportlink.css" rel="stylesheet" type="text/css">

<style>
.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: block;
	margin-left: 16px;
}
</style>
</head>
<script src="../../../Ajax/ajax.js"></script>
<script src="../../../jscript/common.js"></script>
<script src="../../../jscript/date-picker.js"></script>

<script language="JavaScript">

function checkAllSaveItems() {			
	var maxDisp = document.form_.item_count.value;
	var bolIsSelAll = document.form_.selAllSaveItems.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function viewRecord(){
	document.form_._search.value = '1';
	document.form_.submit();
}

function AddInventory(){
	var bookType = document.form_.book_type.value;
	
	if(bookType.length == 0){
		alert("Please select book type first.");
		return;
	}
	if(!confirm("Do you want to add this item(s) to "+document.form_.book_type[document.form_.book_type.selectedIndex].text+" inventory?"))
		return;
	
	document.form_.page_action.value = '1';
	document.form_.submit();
	
}

function updateRecord(strBookIndex){	
	var pgLoc = "edit_inventory_item.jsp?info_index="+strBookIndex+"&LOC_INDEX="+document.form_.LOC_INDEX.value;
	var win=window.open(pgLoc,"updateRecord",'width=900,height=400,top=10,left=0,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<%@ page language="java" import="utility.*,lms.CirculationReport,java.util.Vector" %>
<%
	String strTemp = null;
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strUserIndex  = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-INVENTORY","view_inventory.jsp");
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
														"LIB_Cataloging","INVENTORY",request.getRemoteAddr(),
														"view_inventory.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
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
CirculationReport CR = new CirculationReport();
Vector vRetResult = new Vector();
int iSearchResult = 0;


if(WI.fillTextValue("_search").length() > 0){
	vRetResult = CR.operateOfInventory(dbOP, request, 5);
	if(vRetResult == null)
		strErrMsg = CR.getErrMsg();
	else
		iSearchResult = CR.getSearchCount();
}

%>
<body bgcolor="#D0E19D">
<form action="./view_inventory.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#77A251"> 
      <td height="25" colspan="4"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          INVENTORY MAIN ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3" color="#FF0000"><strong> 
        <%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="10%" height="23"><font size="1">Library Location</font> </td>
      <td width="60%">&nbsp; 
	  	<select name="LOC_INDEX" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">          
          <%=dbOP.loadCombo("LOC_INDEX","LOC_NAME"," from LMS_LIBRARY_LOC order by LOC_INDEX asc",WI.fillTextValue("LOC_INDEX"), false)%> </select>
	  </td>
	  <td>&nbsp;</td>
    </tr>
	
	<tr> 
      <td width="10%" height="23"><font size="1">Material Type</font> </td>
      <td width="50%">&nbsp;
	  	<select name="MATERIAL_TYPE_INDEX" 
	  		style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10; width:300px;">
          <%=dbOP.loadCombo("MATERIAL_TYPE_INDEX","MATERIAL_TYPE"," from LMS_MAT_TYPE order by  MATERIAL_TYPE_INDEX asc",
		  	WI.fillTextValue("MATERIAL_TYPE_INDEX"), false)%> 
        </select>
        <!--<select name="book_type" style="font-family:Verdana, Arial, Helvetica, sans-serif;font-size: 10;">
          <option value="">Select Book Type</option>
          <%
		//strTemp = WI.fillTextValue("book_type");
		///if(strTemp.equals("1")){
		%>
          <option value="1" selected>Book</option>
          <%//}else{%>
          <option value="1">Book</option>
          <%//}if(strTemp.equals("0")){%>
          <option value="0" selected>Non-Book</option>
          <%//}else{%>
          <option value="0">Non-Book</option>
          <%//}%>
        </select>--></td>	  
    </tr>
	
	
	<tr><td colspan="3" height="15">&nbsp;</td></tr>
	<tr>  
	  <td>&nbsp;</td>     
      <td width="" colspan="2">&nbsp;
	  <a href="javascript:viewRecord();">
	  <img src="../../images/form_proceed.gif" border="0"></a>
	  </td>	  
    </tr>
	
    <tr> 
      <td height="19" colspan="4"><div align="right">  
          <hr size="1">
        </div></td>
    </tr>
  </table>
  
 
<%if(vRetResult != null && vRetResult.size() > 0){%> 
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="25" align="center" colspan="3"><strong>Search Result</strong></td></tr>	
	<tr><td colspan="3" height="15">&nbsp;</td></tr>
</table>  


<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr> 
		<td class="thinborder" colspan="4">
			<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(CR.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
		<td class="thinborderBOTTOM" height="25" colspan="7"> &nbsp;
		<%
			int iPageCount = 1;
			iPageCount = iSearchResult/CR.defSearchSize;		
			if(iSearchResult % CR.defSearchSize > 0)
				++iPageCount;
			strTemp = " - Showing("+CR.getDisplayRange()+")";
			if(iPageCount > 1){%> 
				<div align="right">Jump To page: 
				<select name="jumpto" onChange="document.form_._search.value='1';document.form_.submit();">
				<%
					strTemp = WI.fillTextValue("jumpto");
					if(strTemp == null || strTemp.trim().length() ==0)
						strTemp = "0";
					int i = Integer.parseInt(strTemp);
					if(i > iPageCount)
						strTemp = Integer.toString(--i);
		
					for(i = 1; i<= iPageCount; ++i ){
						if(i == Integer.parseInt(strTemp) ){%>
							<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
						<%}
					}%>
				</select></div>
			<%}%> </td>
	</tr>

	<tr>
		<td width="5%" class="thinborder" align="center">Count</td>
		<td width="10%" class="thinborder" align="center" height="25">Collection Type</td>
		<td width="10%" class="thinborder" align="center" height="25">Accession No</td>
		<td width="15%" class="thinborder" align="center">Call No</td>
		<td width="" class="thinborder" align="center">Book Title</td>
		<td width="15%" class="thinborder" align="center">Author</td>
		<td width="10%" class="thinborder" align="center">Edition</td>
		<td width="7%" class="thinborder" align="center">Option</td>		
	</tr>
	
	<%
	int iCount = 1;
	for(int i =0; i<vRetResult.size(); i+=18, iCount++){
	%>
	<tr>
		<td class="thinborder" align="center" height="25"><%=iCount%></td>
		<td class="thinborder">&nbsp;<font size="1"><img src="../../images/<%=(String)vRetResult.elementAt(i + 8)%>" border="1">
	  &nbsp;<%=(String)vRetResult.elementAt(i + 7)%></font></td>
		<td class="thinborder" align="left">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1))%></td>
		<td class="thinborder" align="left">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+15))%></td>
		
		<td class="thinborder" align="left">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%></td>
		<td class="thinborder" align="left">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+9))%></td>
		<td class="thinborder" align="left">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>		
		<td class="thinborder" align="center">&nbsp;
		<a href="javascript:updateRecord('<%=(String)vRetResult.elementAt(i)%>');">
	  	<img src="../../images/update.gif" border="0" align="absmiddle"></a>
		</td>
	</tr>
	<%}%>
	<input type="hidden" name="item_count" value="<%=iCount%>" >
</table>
<%}%>
  
<input type="hidden" name="user_id" value="<%=WI.fillTextValue("user_id")%>"  />
<input type="hidden" name="_search" value="<%=WI.fillTextValue("_search")%>"/>
<input type="hidden" name="page_action" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>